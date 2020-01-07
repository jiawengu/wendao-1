-- WelfareDlg.lua
-- Created by zhengjh Apr/14/2015
-- 福利界面

local WelfareDlg = Singleton("WelfareDlg", Dialog)

local CONFIG_DATA =
    {
        ["WelfareButton0"] = "HolidayGiftDlg",      -- 节日礼包
        ["WelfareButton1"] = "OnlineGiftDlg",       -- 神秘大礼
        ["WelfareButton2"] = "DailySignDlg",        -- 每日签到
        ["WelfareButton3"] = "NoviceGiftDlg",       -- 新手礼包
        ["WelfareButton4"] = "FirstChargeGiftDlg",       -- 新手礼包
        ["WelfareButton5"] = "ChargeDrawGiftDlg",       -- 抽奖
        ["WelfareButton7"] = "SevenDaysRewardDlg",  -- 7天登入界面
        ["WelfareButton8"] = "ZaixqyDlg",  -- 老玩家回归，再续前缘
        ["WelfareButton9"] = "ActiveDrawDlg",  -- 活跃抽奖
        ["WelfareButton10"] = "BachelorDrawDlg",  -- 活跃抽奖
        ["WelfareButton11"] = "ScratchRewardDlg", -- 寒假刮刮乐
        ["WelfareButton12"] = "ChunjieRedBagDlg", -- 春节幸运红包
        ["WelfareButton13"] = "ChargePointDlg", -- 充值积分
        ["WelfareButton14"] = "CallBackDlg", -- 再续前缘
        ["WelfareButton15"] = "ActiveVIPDlg", -- 活跃送会员
        ["WelfareButton16"] = "ChargeGiftPerMonthDlg", -- 活跃送会员
        ["WelfareButton17"] = "SummerVacationDlg", -- 活跃送会员
        ["WelfareButton18"] = "RenameDiscountDlg", -- 5折改名卡
        ["WelfareButton19"] = "ZaoHuaDlg", -- 造化之池
        ["WelfareButton20"] = "ChargePointDlg", -- 消费积分
        ["WelfareButton21"] = "WelcomNewDlg", -- 迎新抽奖
        ["WelfareButton22"] = "ActiveLoginRewardDlg", -- 活跃登录礼包
        ["WelfareButton23"] = "MergeLoginGiftDlg", -- 合服登录礼包
        ["WelfareButton24"] = "CombinedServiceTaskDlg", -- 合服促活跃
        ["WelfareButton25"] = "XunDaoCiFuDlg", -- 寻道赐福
        ["WelfareButton26"] = "ExpStoreHouseDlg", -- 经验仓库
        ["WelfareButton27"] = "NewServiceExpDlg", -- 新服助力
        ["WelfareButton28"] = "SeekFriendMemberDlg", -- 寻友福利
        ["WelfareButton29"] = "RegressionRechargeDlg", -- 回归累充
        ["WelfareButton30"] = "NewServiceCelebrationDlg", -- 新服盛典
    }

local RewardStep =
    {
        start = 1,
        rewardEnd = 2,
        close = 3,
    }

local btnFun =
    {
        ["WelfareButton0"] = "onHolidayGiftDlg",      -- 节日礼包
        ["WelfareButton1"] = "onlineGift",       -- 神秘大礼
        ["WelfareButton2"] = "onDailySign",        -- 每日签到
        ["WelfareButton3"] = "onNewPalyerGift",       -- 新手礼包
        ["WelfareButton4"] = "onFirstChargeGift",       -- 新手礼包
        ["WelfareButton5"] = "onChargeDrawGiftDlg",       -- 抽奖
        ["WelfareButton7"] = "onSevenDaysRewardDlg", -- 7天登入界面
        ["WelfareButton8"] = "onZaixqyDlg", -- 老玩家回归，再续前缘
        ["WelfareButton9"] = "onActiveDrawDlg",  -- 活跃抽奖
        ["WelfareButton10"] = "onBachelorDrawDlg",  -- 活跃抽奖
        ["WelfareButton11"] = "onScratchRewardDlg", -- 寒假刮刮乐
        ["WelfareButton12"] = "onChunjieRedBagDlg", -- 春节幸运红包
        ["WelfareButton13"] = "onChargePointDlg", -- 充值积分
        ["WelfareButton14"] = "onCallBackDlg", -- 再续前缘
        ["WelfareButton15"] = "onActiveVIPDlg", --活跃送会员
        ["WelfareButton16"] = "onChargeGiftPerMonthDlg", --活跃送会员
        ["WelfareButton17"] = "onSummerVacationDlg", -- 活跃送会员
        ["WelfareButton18"] = "onRenameDiscountDlg", -- 5折改名卡
        ["WelfareButton19"] = "onZaoHuaDlg", -- 造化之池
        ["WelfareButton20"] = "onChargePointDlg", -- 消费积分
        ["WelfareButton21"] = "onWelcomNewDlg", -- 迎新抽奖
        ["WelfareButton22"] = "onActiveLoginRewardDlg", -- 活跃登录礼包
        ["WelfareButton23"] = "onMergeLoginGiftDlg", -- 活跃登录礼包
        ["WelfareButton24"] = "onCombinedServiceTaskDlg", -- 活跃登录礼包
        ["WelfareButton25"] = "onXunDaoCiFuDlg", -- 活跃登录礼包
        ["WelfareButton26"] = "onExpStoreHouseDlg", -- 经验仓库
        ["WelfareButton27"] = "onNewServiceExpDlg", -- 新服助力
        ["WelfareButton28"] = "onSeekFriendMemberDlg", -- 寻友福利
        ["WelfareButton29"] = "onRegressionRechargeDlg", -- 回归累充
        ["WelfareButton30"] = "onNewServiceCelebrationDlg", -- 新服盛典
    }

local ITEM_MAX = 29

function WelfareDlg:init()
    if GiftMgr.isOpenNewLottery then
        btnFun["WelfareButton5"] = "onNewChargeDrawGiftDlg"
        CONFIG_DATA["WelfareButton5"] = "NewChargeDrawGiftDlg"
    end

    for btmName, funName in pairs(btnFun) do
        self:bindListener(btmName, self[funName])
    end

    self:hookMsg("MSG_OPEN_WELFARE")
    self:hookMsg("MSG_FESTIVAL_LOTTERY")

    local scrollCtrl = self:getControl("WelfareTabPanel")
    scrollCtrl:setTouchEnabled(false)
--
    self:setAllSelectVisible(false)
    self.welfareData = GiftMgr:getWelfareData()
    if self.welfareData then
        -- 初始化判断首充和七天和新手礼包是否需要隐藏
        self:setButtonInit()
    end
--]]
    self.lastSlecetKey = self.lastSlecetKey or GiftMgr:getLastIndex()
    GiftMgr:openGift()
    --self:hookMsg("MSG_NEWBIE_GIFT")

    self.childTag = {}
end



-- 隐藏所有按钮
function WelfareDlg:setAllSelectVisible(isVisible)
    local y = 0
    for i = ITEM_MAX, 0, -1 do
        local tempPanel = self:getControl("WelfareScrollPanel" .. i)
        if tempPanel then
            tempPanel:setVisible(isVisible)
            if isVisible then
                tempPanel:setPositionY(y)
                y = y + tempPanel:getContentSize().height + 2
            end
        end
    end

    local panel = self:getControl("Panel", nil, "WelfareScrollView")
    local scrollCtrl = self:getControl("WelfareScrollView")
    panel:setContentSize(scrollCtrl:getContentSize().width, y)
    scrollCtrl:setInnerContainerSize(panel:getContentSize())
    panel:requestDoLayout()
end

-- 首充和七天还有新手礼包如果都领取完，需要隐藏
function WelfareDlg:setButtonInit()
    -- 控件名 button后面带的数字和父panel带的数字不一样！
    -- 首充领取完

    if self.welfareData["firstChargeState"] == 2 then
        local panel = self:getControl("WelfareButton4"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 7天登入
    if self.welfareData["loginGiftState"] == 2 then
        local panel = self:getControl("WelfareButton7"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 新手礼包
    if self.welfareData["isCanGetNewPalyerGift"] == 0 and Me:queryBasicInt("level") >= math.floor(Const.PLAYER_MAX_LEVEL / 10) * 10 then
        local panel = self:getControl("WelfareButton3"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 再续前缘
    if self.welfareData["isShowHuiGui"] <= 0 then
        local panel = self:getControl("WelfareButton8"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 活跃抽奖
    if self.welfareData["activeCount"] < 0 then
        local panel = self:getControl("WelfareButton9"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 节日活动
    if self.welfareData["holidayCount"] < 0 or Me:queryBasicInt("level") < 30 then
        local panel = self:getControl("WelfareButton0"):getParent()
        if panel then panel:removeFromParent() end
    else
        if ActivityMgr:isHaveFestivalStartByName(CHS[5120007]) then
            local panel = self:getControl("WelfareButton0"):getParent()
            self:setLabelText("NameLabel0", CHS[4101210], panel)
        end
    end

    -- 光棍节抽奖活动
    if not self.welfareData["lottery"]["singles_day_2016"] then
        local panel = self:getControl("WelfareButton10"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 寒假刮刮乐
    if not self.welfareData["lottery"]["winter_day_2017"] then
        local panel = self:getControl("WelfareButton11"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 春节幸运红包
    if not self.welfareData["lottery"]["spring_day_2017"] then
        local panel = self:getControl("WelfareButton12"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 充值积分
    if self.welfareData["chargePointFlag"] < 0 then
        local panel = self:getControl("WelfareButton13"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 召回道友
    if self.welfareData["isShowZhaohui"] <= 0 then
        local panel = self:getControl("WelfareButton14"):getParent()
        if panel then panel:removeFromParent() end
    else
        GiftMgr:queryCallBackData()
    end

    -- 活跃送会员
    if self.welfareData["activeVIPFlag"] <= 0 then
        local panel = self:getControl("WelfareButton15"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 暑假送福，还没制作，先屏蔽
    if self.welfareData["summerSF2017"] <= 0 then
        local panel = self:getControl("WelfareButton17"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 五折改名
    if self.welfareData["rename_discount_time"] <= 0 then
        local panel = self:getControl("WelfareButton18"):getParent()
        if panel then panel:removeFromParent() end
    end

    if not self.welfareData["isShowMonthCharge"] or self.welfareData["isShowMonthCharge"] <= 0 then
        local panel = self:getControl("WelfareButton16"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 造化之池
    if self.welfareData["zaohua"] < 0 then
        local panel = self:getControl("WelfareButton19"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 消费积分
    if self.welfareData["consumePointFlag"] < 0 then
        local panel = self:getControl("WelfareButton20"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 迎新抽奖
    if self.welfareData["welcomeDrawStatue"] < 0 then
        local panel = self:getControl("WelfareButton21"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 活跃登录礼包
    if self.welfareData["activeLoginStatue"] < 0 then
        local panel = self:getControl("WelfareButton22"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 合服登录礼包
    if self.welfareData["mergeLoginStatus"] < 0 then
        local panel = self:getControl("WelfareButton23"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 合服促活跃
    if self.welfareData["mergeLoginActiveStatus"] < 0 then
        local panel = self:getControl("WelfareButton24"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 寻道赐福
    if self.welfareData["xundcf"] < 0 then
        local panel = self:getControl("WelfareButton25"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 经验仓库
    if self.welfareData["expStoreStatus"] <= 0 then
        local panel = self:getControl("WelfareButton26"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 新服助力
    if self.welfareData["newServeAddNum"] <= 0 then
        local panel = self:getControl("WelfareButton27"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 寻友福利
    if not self.welfareData["isShowXYFL"] or self.welfareData["isShowXYFL"] < 0 then
        local panel = self:getControl("WelfareButton28"):getParent()
        if panel then panel:removeFromParent() end
    else
        -- 为了表现好，先请求数据，防止切换过无数据
        gf:CmdToServer("CMD_BJTX_WELFARE")
    end

    -- 回归累充
    if self.welfareData["reentryAsktaoRecharge"] < 0 then
        local panel = self:getControl("WelfareButton29"):getParent()
        if panel then panel:removeFromParent() end
    end

    -- 新服盛典
    if self.welfareData["isShowXFSD"] <= 0 then
        local panel = self:getControl("WelfareButton30"):getParent()
        if panel then panel:removeFromParent() end
    end

    self:setAllSelectVisible(true)
    self:updateLayout("WelfareScrollView")
end

function WelfareDlg:selectBtnByDlg(dlgName)
    if dlgName == "HolidayGiftDlg" then
        self:onlineGift(self:getControl("WelfareButton0"))
    elseif dlgName == "OnlineGiftDlg" then
        self:onlineGift(self:getControl("WelfareButton1"))
    elseif dlgName == "DailySignDlg" then
        self:onDailySign(self:getControl("WelfareButton2"))
    elseif dlgName == "NoviceGiftDlg" then
        self:onNewPalyerGift(self:getControl("WelfareButton3"))
    elseif dlgName == "FirstChargeGiftDlg" then
        self:onFirstChargeGift(self:getControl("WelfareButton4"))
    elseif dlgName == "ChargeDrawGiftDlg" then
        self:onChargeDrawGiftDlg(self:getControl("WelfareButton5"))
    elseif dlgName == "NewChargeDrawGiftDlg" then
        self:onNewChargeDrawGiftDlg(self:getControl("WelfareButton5"))
    elseif dlgName == "SevenDaysRewardDlg" then
        self:onSevenDaysRewardDlg(self:getControl("WelfareButton7"))
    elseif dlgName == "ReentryAsktaoDlg" then
        self:onReentryAsktaoDlg(self:getControl("WelfareButton8"))
    elseif dlgName == "ActiveDrawDlg" then
        self:onActiveDrawDlg(self:getControl("WelfareButton9"))
    elseif dlgName == "BachelorDrawDlg" then
        self:onBachelorDrawDlg(self:getControl("WelfareButton10"))
    elseif dlgName == "ScratchRewardDlg" then
        self:onScratchRewardDlg(self:getControl("WelfareButton11"))
    elseif dlgName == "ChunjieRedBagDlg" then
        self:onChunjieRedBagDlg(self:getControl("WelfareButton12"))
    elseif dlgName == "ActiveLoginRewardDlg" then
        self:onActiveLoginRewardDlg(self:getControl("WelfareButton22"))
    elseif dlgName == "MergeLoginGiftDlg" then
        self:onMergeLoginGiftDlg(self:getControl("WelfareButton23"))
    elseif dlgName == "CombinedServiceTaskDlg" then
        self:onCombinedServiceTaskDlg(self:getControl("WelfareButton24"))
    elseif dlgName == "ExpStoreHouseDlg" then
        self:onExpStoreHouseDlg(self:getControl("WelfareButton26"))
    elseif dlgName == "NewServiceExpDlg" then
        self:onNewServiceExpDlg(self:getControl("WelfareButton27"))
    elseif dlgName == "SeekFriendMemberDlg" then
        self:onSeekFriendMemberDlg(self:getControl("WelfareButton28"))
    elseif dlgName == "RegressionRechargeDlg" then
        self:onRegressionRechargeDlg(self:getControl("WelfareButton29"))
    elseif dlgName == "NewServiceCelebrationDlg" then
        self:onNewServiceCelebrationDlg(self:getControl("WelfareButton30"))
    end
end

function WelfareDlg:MSG_OPEN_WELFARE()
end



function WelfareDlg:MSG_FESTIVAL_LOTTERY()
    if not self.welfareData then
        self.welfareData = GiftMgr:getWelfareData()
        self:setButtonInit()
    end

    self.welfareData = GiftMgr:getWelfareData()

    -- 每日签到
    --[[  local panel1 = self:getControl("WelfarePanel1", Const.UIPanel )
    local readyLabel1 = self:getControl("ReadyLabel", Const.UILabel, panel1)

    if self.welfareData["isCanSign"] == 1 then
    readyLabel1:setVisible(true)
    else
    readyLabel1:setVisible(false)
    end]]

    RedDotMgr:removeOneRedDot("WelfareDlg", self.lastSlecetKey)
    self[btnFun[self.lastSlecetKey]](self, self:getControl(self.lastSlecetKey))

    -- 神秘大礼
    local panel2 = self:getControl("WelfareScrollPanel1", Const.UIPanel )
    panel2:stopAllActions()
    if  self.welfareData["leftTimes"] > 0 then
        if self.welfareData["leftTimes"] == self.welfareData["times"] and self.welfareData["leftTime"] == 0 then
        else
            local time = self.welfareData["leftTime"]
            schedule(panel2 ,
                function() if time == 0 then
                    GiftMgr:openGift()
                    GiftMgr:openOnlineGift()
                    panel2:stopAllActions()
                    return
                end

                time = time - 1  end, 1)
        end

        if self.welfareData.times > 0 then
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        end
    end

    if self.lastSlecetKey ~= "WelfareButton1" and self.welfareData["times"] > 0 then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton1")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton1")
    end

    -- 每日签到
    if  self.welfareData["isCanSign"] == 1 and self.lastSlecetKey ~= "WelfareButton2" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton2")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton2")
    end

    -- 新手礼包
    if  self.welfareData["isCanGetNewPalyerGift"] == 1 and self.lastSlecetKey ~= "WelfareButton3" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton3")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton3")
    end

    -- 首充
    if  self.welfareData["firstChargeState"] == 1 and self.lastSlecetKey ~= "WelfareButton4" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton4")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton4")
    end

    self:setCtrlVisible("ChoosenEffectImage", true, self.lastSlecetKey)

    -- 累充
    if 0 ~= self.welfareData["cumulativeReward"] and self.lastSlecetKey ~= "WelfareButton6" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton6")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton6")
    end

    -- 7天
    if self.welfareData["loginGiftState"] == 1 and self.lastSlecetKey ~= "WelfareButton7" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton7")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton7")
    end

    -- 再续前缘
    if self.lastSlecetKey ~= "WelfareButton8" then
        if self.welfareData["canGetZXQYSevenLogin"] > 0
            or self.welfareData["canGetZXQYHuoYue"] > 0 then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton8")
        end
    end

    if self.welfareData["canGetZXQYSevenLogin"] > 0 and self.welfareData["isShowHuiGui"] > 0 then
        RedDotMgr:insertOneRedDot("ZaixqyDlg", "GoSevenGiftButton", "ActivitiesUnitPanel1_2")
    elseif RedDotMgr:hasRedDotInfo("ZaixqyDlg", "GoSevenGiftButton") then
        RedDotMgr:removeOneRedDot("ZaixqyDlg", "GoSevenGiftButton", "ActivitiesUnitPanel1_2")
    end

    if self.welfareData["canGetZXQYHuoYue"] > 0 and self.welfareData["isShowHuiGui"] > 0 then
        RedDotMgr:insertOneRedDot("ZaixqyDlg", "GoHuoyueButton", "ActivitiesUnitPanel2")
    elseif RedDotMgr:hasRedDotInfo("ZaixqyDlg", "GoHuoyueButton") then
        RedDotMgr:removeOneRedDot("ZaixqyDlg", "GoHuoyueButton", "ActivitiesUnitPanel2")
    end

    if self.welfareData["activeCount"] > 0 and self.lastSlecetKey ~= "WelfareButton9" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton9")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton9")
    end

    if self.welfareData["holidayCount"] > 0 and self.lastSlecetKey ~= "WelfareButton0" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton0")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton0")
    end

    if self.welfareData["lottery"]["singles_day_2016"] and self.welfareData["lottery"]["singles_day_2016"].amount > 0 and self.lastSlecetKey ~= "WelfareButton10" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton10")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton10")
    end

    if self.welfareData["lottery"]["winter_day_2017"] and self.welfareData["lottery"]["winter_day_2017"].amount > 0 and self.lastSlecetKey ~= "WelfareButton11" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton11")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton11")
    end

    if Me:queryInt("level") >= 30 and self.welfareData["lottery"]["spring_day_2017"] and self.welfareData["lottery"]["spring_day_2017"].amount > 0 and self.lastSlecetKey ~= "WelfareButton12" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton12")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton12")
    end

    if Me:queryBasicInt("lock_exp") == 0 and self.welfareData["zaohua"] > 0 and self.lastSlecetKey ~= "WelfareButton19" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton19")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton19")
    end

    if Me:queryBasicInt("lock_exp") == 0 and self.welfareData["xundcf"] > 0 and self.lastSlecetKey ~= "WelfareButton25" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton25")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton25")
    end

    if self.welfareData["isShowXYFL"] > 0 and self.lastSlecetKey ~= "WelfareButton28" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton28")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton28")
    end

    -- 充值积分小红点
    -- 活动期间首次登录
    if GiftMgr:isInRechargeScore() and GiftMgr:isCanAddRedDot("WelfareButton13") and GameMgr.isFirstLoginToday then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton13")
        GiftMgr:setCanAddRedDot("WelfareButton13", false)
    end

    -- 活动结束，但仍处于兑换时间，玩家当前积分>=7
    if GiftMgr:isInRechargeScoreDeadline() and
          GiftMgr:getRechargeScore() >= GiftMgr:getMinPointInRechargeScoreDeadline() and
          self.lastSlecetKey ~= "WelfareButton13" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton13")
    end


    -- 消费积分小红点
    -- 活动期间首次登录
    if GiftMgr:isInConsumeScore() and GiftMgr:isCanAddRedDot("WelfareButton20") and GameMgr.isFirstLoginToday then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton20")
        GiftMgr:setCanAddRedDot("WelfareButton20", false)
    end

    -- 活动结束，但仍处于兑换时间，玩家当前积分>=7
    if GiftMgr:isInConsumeScoreDeadline() and
        GiftMgr:getConsumeScore() >= GiftMgr:getMinPointInConsumeScoreDeadline() and
        self.lastSlecetKey ~= "WelfareButton20" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton20")
    end


    -- 活跃送会员
    -- 活动期间每日首次登录（若已经领取过奖励则不显示红点）
    local activeVIPInfo = GiftMgr:getActiveVIPInfo()
    if activeVIPInfo and activeVIPInfo.show_reddot and activeVIPInfo.show_reddot >= 1
          and activeVIPInfo.fetch_state and activeVIPInfo.fetch_state ~= 2
          and GiftMgr:isCanAddRedDot("WelfareButton15")
          and GameMgr.isFirstLoginToday then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton15")
        GiftMgr:setCanAddRedDot("WelfareButton15", false)
    end

    -- 有会员奖励可领取时（无视每次首次登录要求）
    if activeVIPInfo and activeVIPInfo.fetch_state and activeVIPInfo.fetch_state == 1
          and self.lastSlecetKey ~= "WelfareButton15" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton15")
    end

    -- 暑假送福
    if self.welfareData.summerSF2017 and self.welfareData.summerSF2017 == 2 and self.lastSlecetKey ~= "WelfareButton17" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton17")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton17")
    end

    -- 月首充可领取，或首次充值成功
    if self.welfareData.isShowMonthCharge
        and self.welfareData.isShowMonthCharge ~= 0
        and GiftMgr["month_charge_gift"]
        and self.lastSlecetKey ~= "WelfareButton16"
        and GiftMgr["month_charge_gift"].amount == 1 then

        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton16")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton16")
    end

    -- 迎新抽奖
    if self.welfareData.welcomeDrawStatue == 1 and self.lastSlecetKey ~= "WelfareButton21" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton21")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton21")
    end

    -- 活跃登录礼包
    if self.welfareData["activeLoginStatue"] == 1
        and Me:getLevel() >= GiftMgr:getActiveLoginGiftLimitLevel()
        and self.lastSlecetKey ~= "WelfareButton22" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton22")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton22")
    end

    -- 合服登录礼包
    if  Me:queryInt("level") >= GiftMgr:getMergerLoginGiftLimitLevel() and self.welfareData["mergeLoginStatus"] == 1 and self.lastSlecetKey ~= "WelfareButton23" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton23")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton23")
    end

    -- 合服促活跃
    if  self.welfareData["mergeLoginActiveStatus"] == 1 and self.lastSlecetKey ~= "WelfareButton24" then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton24")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton24")
    end

    -- 经验仓库
    if self.welfareData["expStoreStatus"] > 0
        and self.lastSlecetKey ~= "WelfareButton26"
        and Me:queryBasicInt("exp_ware_data/exp_ware") > 0
        and Me:queryBasicInt("exp_ware_data/today_fetch_times") == 0
        and not Me:isLockExp() then
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton26")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton26")
    end

    -- 每次登录首次打开。并且首充已充值未领取光效
    if GiftMgr.firstOpenWelfareDlg and self.welfareData["firstChargeState"] == 1 then
        local btn = self:getControl("WelfareButton4")
        local effect = btn:getChildByTag(ResMgr.magic.first_login_charge)
        if not effect then
            -- lixh2 WDSY-21401 帧光效替换
            local extraPara = {["blendMode"] = "add"}
            local effect =  gf:createLoopMagic(ResMgr.magic.first_login_charge, MAGIC_TYPE.NORMAL, extraPara)
            local btn = self:getControl("WelfareButton4")
            effect:setAnchorPoint(0.5, 0.5)
            effect:setPosition(btn:getContentSize().width / 2,btn:getContentSize().height / 2)
            effect:setContentSize(btn:getContentSize())
            btn:addChild(effect, 1, ResMgr.magic.first_login_charge)
        end
    end

    -- 回归累充
    if (self.welfareData["reentryAsktaoRecharge"] == 1 or
        (GameMgr.isFirstLoginToday and self.welfareData["reentryAsktaoRecharge"] == 0))
        and self.lastSlecetKey ~= "WelfareButton29" then
        -- 首次登陆活动开启，或当前奖励可领取时，增加红点
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton29")
    else
        RedDotMgr:removeOneRedDot("WelfareDlg", "WelfareButton29")
    end

    GiftMgr.firstOpenWelfareDlg = false
end

function WelfareDlg:getTimeStr(time)
    local hours = math.floor(time / 3600)
    local minute = math.floor(time % 3600 /60)
    local second = time % 60

    local str = string.format("%02d:%02d", minute, second )

    return str
end

function WelfareDlg:onHolidayGiftDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("HolidayGiftDlg")
end

function WelfareDlg:onDailySign(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("DailySignDlg")
end

function WelfareDlg:onlineGift(sender, enventType)
    self:addSelcetImage(sender)
    if not DlgMgr:getDlgByName("OnlineGiftDlg") then
        DlgMgr:openDlg("OnlineGiftDlg")
    else
        -- 如果对话框已经存在，请求数据更新（重新打开如果在剧本情况下，会被设置为可见）
        GiftMgr:openOnlineGift()
    end
end

function WelfareDlg:onNewPalyerGift(sender, enventType)
    -- 请求礼包
    self:addSelcetImage(sender)
    DlgMgr:openDlg("NoviceGiftDlg")
end

-- 7天登入界面
function WelfareDlg:onSevenDaysRewardDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("SevenDaysRewardDlg")
end

-- 再续前缘
function WelfareDlg:onReentryAsktaoDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ReentryAsktaoDlg")
end

-- 活跃抽奖
function WelfareDlg:onActiveDrawDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ActiveDrawDlg")
end

-- 单身抽奖
function WelfareDlg:onBachelorDrawDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("BachelorDrawDlg")
end

-- 寒假刮刮乐
function WelfareDlg:onScratchRewardDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ScratchRewardDlg")
end

-- 春节幸运红包
function WelfareDlg:onChunjieRedBagDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ChunjieRedBagDlg")
end

function WelfareDlg:onFirstChargeGift(sender, enventType)
    -- 请求礼包
    self:addSelcetImage(sender)
    DlgMgr:openDlg("FirstChargeGiftDlg")

    local magic = sender:getChildByTag(ResMgr.magic.first_login_charge)
    if magic then
        magic:removeFromParent()
    end
end

function WelfareDlg:onChargeDrawGiftDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ChargeDrawGiftDlg")
end

function WelfareDlg:onNewChargeDrawGiftDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("NewChargeDrawGiftDlg")
end

function WelfareDlg:onZaixqyDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ZaixqyDlg")
end

function WelfareDlg:onCallBackDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("CallBackDlg")
end

function WelfareDlg:onChargePointDlg(sender, enventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ChargePointDlg")
end

function WelfareDlg:onActiveVIPDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ActiveVIPDlg")
end

-- 点击 造化
function WelfareDlg:onZaoHuaDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ZaoHuaDlg")
end

-- 点击 5折改名卡
function WelfareDlg:onRenameDiscountDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("RenameDiscountDlg")
end

function WelfareDlg:onChargeGiftPerMonthDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ChargeGiftPerMonthDlg")
end

function WelfareDlg:onSummerVacationDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("SummerVacationDlg")
end

function WelfareDlg:onWelcomNewDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("WelcomNewDlg")
end

function WelfareDlg:onActiveLoginRewardDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ActiveLoginRewardDlg")
end

function WelfareDlg:onXunDaoCiFuDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("XunDaoCiFuDlg")
end

function WelfareDlg:onExpStoreHouseDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("ExpStoreHouseDlg")
end


function WelfareDlg:onSeekFriendMemberDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("SeekFriendMemberDlg")
end


function WelfareDlg:onRegressionRechargeDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("RegressionRechargeDlg")
end

function WelfareDlg:onNewServiceCelebrationDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("NewServiceCelebrationDlg")
end

function WelfareDlg:onNewServiceExpDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("NewServiceExpDlg")
end

function WelfareDlg:onMergeLoginGiftDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("MergeLoginGiftDlg")
end

function WelfareDlg:onCombinedServiceTaskDlg(sender, eventType)
    self:addSelcetImage(sender)
    DlgMgr:openDlg("CombinedServiceTaskDlg")
end

function WelfareDlg:addSelcetImage(cell)
    if not cell then return end
    if self.lastSlecetKey  == cell:getName() then
        self:setCtrlVisible("ChoosenEffectImage", true, cell:getParent())
        return
    end

    for i = 0, ITEM_MAX do
        local itemPanel = self:getControl("WelfareScrollPanel" .. i)
        if itemPanel then
            self:setCtrlVisible("ChoosenEffectImage", false, itemPanel)
        end
    end

    self:setCtrlVisible("ChoosenEffectImage", true, cell:getParent())

    -- 关闭上次选中的界面
    if self.lastSlecetKey then
        DlgMgr:closeThisDlgOnly(CONFIG_DATA[self.lastSlecetKey])
    end

    self.lastSlecetKey = cell:getName()

    GiftMgr:setLastIndex(self.lastSlecetKey )

    if GiftMgr:getonlineData() then
        GiftMgr:getReward(GiftMgr:getonlineData()["type"], 3) -- 关闭抽奖
    end

    self:MSG_FESTIVAL_LOTTERY()

    -- 清除各个福利界面添加在tab框上的控件
    for _, tag in pairs(self.childTag) do
        self:romoveOtherChildByTag(tag)
    end
end

function WelfareDlg:cleanup()
    self.lastSlecetKey = nil
    GiftMgr:setLastTime()
    for _, dlg in pairs(CONFIG_DATA) do
        DlgMgr:closeThisDlgOnly(dlg)
        DlgMgr:closeThisDlgOnly("Funny4Dlg")
    end
    if nil == GiftMgr:getonlineData() then
        if GiftMgr:getWelfareData() then
            performWithDelay(gf:getUILayer(), function ()
                -- RedDotMgr:MSG_OPEN_WELFARE(GiftMgr:getWelfareData())
                -- WDSY-36017 福利活动领奖后，若在关闭界面之前没有收到 MSG_OPEN_WELFARE 消息，那么延迟1帧
                -- 使用的 GiftMgr:getWelfareData() 就是错误的数据，会导致误添加小红点，所以调整为请求一次数据
                -- 并在收到 MSG_OPEN_WELFARE 消息中以最后一次收到该消息的数据用来判断是否需要添加小红点
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_WELFARE)
            end, 0)
        end

        return
    end

    GiftMgr:getReward(GiftMgr:getonlineData()["type"], RewardStep["close"])
end

-- 福利界面在tab界面添加控件
function WelfareDlg:addOtherChild(tag, panel)
    if not  self.childTag then
        self.childTag = {}
    end

    self.childTag[tag] = tag
    self.root:addChild(panel)
end

function WelfareDlg:romoveOtherChildByTag(tag)
    self.root:removeChildByTag(tag)
    self.childTag[tag] = nil
end

return WelfareDlg
