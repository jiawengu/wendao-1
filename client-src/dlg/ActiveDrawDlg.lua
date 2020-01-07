-- ActiveDrawDlg.lua
-- Created by songcw Aug/31/2016
-- 活跃度抽奖

local ActiveDrawDlg = Singleton("ActiveDrawDlg", Dialog)


local REWARD_MAX = 8

ActiveDrawDlg.needCount = 0
ActiveDrawDlg.startPos = 1
ActiveDrawDlg.curPos = 1
ActiveDrawDlg.delay = 1
ActiveDrawDlg.updateTime = 1

ActiveDrawDlg.activeValue = nil

--[[ 配置奖品信息
local BonusInfo = {
    ["liveness_lottery_1"] = {
        [1] = {[1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}},  -- 1倍道行
        [2] = {[1] = {itemIcon = 09002, chs = CHS[3001147]}},                       -- 超级仙风散
        [3] = {[1] = {itemIcon = 09007, chs = CHS[2000184]}},                       -- 天神佑护
        [4] = {[1] = {icon = "ui/Icon0641.png", chs = CHS[2000179], timeLimit = 0, isPlist = 0}},     -- 北极熊
        [5] = {
            [1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}, -- 1倍道行
            [2] = {icon = "ui/Icon0711.png", chs = CHS[5420109], isPlist = 0}, -- 超豪华全套家电
        },
        [6] = {[1] = {icon = "ui/Icon0709.png", chs = CHS[5420106], isPlist = 0}},  -- 苏泊尔电饭煲
        [7] = {[1] = {icon = "ui/Icon0706.png", chs = CHS[5420107], isPlist = 0}},  -- 海尔洗衣机
        [8] = {[1] = {icon = "ui/Icon0708.png", chs = CHS[5420108], isPlist = 0}},  -- 美的微波炉
    },

    ["liveness_lottery_2"] = {
        [1] = {[1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}},  -- 1倍道行
        [2] = {[1] = {itemIcon = 09002, chs = CHS[3001147]}},                       -- 超级仙风散
        [3] = {[1] = {itemIcon = 09007, chs = CHS[2000184]}},                       -- 天神佑护
        [4] = {[1] = {icon = "ui/Icon0641.png", chs = CHS[2000179], timeLimit = 0, isPlist = 0}},     -- 北极熊
        [5] = {[1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}},  -- 1倍道行
        [6] = {[1] = {icon = "ui/Icon0710.png", chs = CHS[5420110], isPlist = 0}},  -- 长虹液晶彩电
        [7] = {[1] = {icon = "ui/Icon0705.png", chs = CHS[5420111], isPlist = 0}},  -- 海尔立式冷冻柜
        [8] = {[1] = {icon = "ui/Icon0707.png", chs = CHS[5420112], isPlist = 0}},  -- 海尔智能拖地机
    },

    ["liveness_lottery_3"] = {
        [1] = {[1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}},  -- 1倍道行
        [2] = {[1] = {itemIcon = 09002, chs = CHS[3001147]}},                       -- 超级仙风散
        [3] = {[1] = {itemIcon = 09007, chs = CHS[2000184]}},                       -- 天神佑护
        [4] = {[1] = {icon = "ui/Icon0641.png", chs = CHS[2000179], timeLimit = 0, isPlist = 0}},     -- 北极熊
        [5] = {
            [1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}, -- 1倍道行
            [2] = {icon = "ui/Icon0711.png", chs = CHS[5420109], isPlist = 0}, -- 超豪华全套家电
        },
        [6] = {[1] = {icon = "ui/Icon0709.png", chs = CHS[5420106], isPlist = 0}},  -- 苏泊尔电饭煲
        [7] = {[1] = {icon = "ui/Icon0706.png", chs = CHS[5420107], isPlist = 0}},  -- 海尔洗衣机
        [8] = {[1] = {icon = "ui/Icon0708.png", chs = CHS[5420108], isPlist = 0}},  -- 美的微波炉
    },

    ["liveness_lottery"] = {
        [1] = {[1] = {icon = ResMgr.ui.daohang, chs = CHS[4300095], isPlist = 1}},  -- 1倍道行
        [2] = {[1] = {icon = ResMgr.ui.big_change_card, chs = CHS[6200003], isPlist = 1}},  -- 随机变身卡
        [3] = {[1] = {icon = ResMgr.ui.reward_big_VIP, chs = CHS[3001795], isPlist = 1}},  -- 位列仙班·年卡
        [4] = {[1] = {itemIcon = 09081, chs = CHS[6200026]}},     -- 宠风散
        [5] = {[1] = {itemIcon = 01800, chs = CHS[5420130]}},     -- 变异召唤令
        [6] = {[1] = {icon = ResMgr.ui.reward_big_VIP, chs = CHS[3001789], isPlist = 1}},  -- 位列仙班·月卡
        [7] = {[1] = {itemIcon = 09002, chs = CHS[3001147]}},     -- 超级仙风散
        [8] = {[1] = {icon = "ui/Icon0723.png", chs = CHS[6000501]}},     -- 岳麓剑
    }

}

-- 不同时间端显示的不同的奖品,未配时间默认选第一个配置的奖品
local ChangeTime = {
    ["liveness_lottery_1"] = {
        [5] = {[1] = {startTime = "20170120050000", endTime = "20170121045959", choose = 2},}
    },

    ["liveness_lottery_3"] = {
        [5] = {
            [1] = {startTime = "20170208050000", endTime = "20170209045959", choose = 2},
            [2] = {startTime = "20170211050000", endTime = "20170212045959", choose = 2},
        }
    }
}]]


-- 配置奖品信息
local BonusInfo = {
    ["liveness_lottery"] = {
        {[1] = {icon = ResMgr.ui.reward_big_daohang, chs = CHS[4100805], isPlist = 1}},  -- 道行
        {[1] = {itemIcon = 01989, chs = CHS[5450374]}},     -- 元神碎片·饮露
        {[1] = {itemIcon = 09006, chs = CHS[3001106]}},     -- 超级归元露
        {[1] = {itemIcon = 09210, chs = CHS[5420247]}},     -- 紫气鸿蒙
        {[1] = {icon = ResMgr.ui.reward_big_jewelry, chs = CHS[5400791], isPlist = 1}},     -- 60级随机首饰
        {[1] = {itemIcon = 01716, chs = CHS[3001105]}},     -- 超级女娲石
        {[1] = {itemIcon = 02006, chs = CHS[7190029]}},     -- 召唤令·上古神兽
        {[1] = {icon = ResMgr.ui.pet_common, chs = CHS[7190034], isPlist = 1}},     -- 十二生肖
    },
}

-- 不同时间端显示的不同的奖品,未配时间默认选第一个配置的奖品
local ChangeTime = {}

function ActiveDrawDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ReentryAsktaoDlg")
end

function ActiveDrawDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
    GiftMgr.lastIndex = "WelfareButton9"
    self:changeShowRewards("liveness_lottery")
    self.curLottery = "liveness_lottery"
    self:resetRewards()

    self.isRotating = false

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_LIVENESS_LOTTERY_RESULT")
    self:hookMsg("MSG_OPEN_WELFARE")
    self:hookMsg("MSG_OPEN_LIVENESS_LOTTERY")



    local data = GiftMgr:getWelfareData() or {}
    if next(data) then
        self:MSG_OPEN_WELFARE(data)
    end

    GiftMgr:requestActiveDrawAct()

    self:updateLayout("WelfarePanel")
end

-- 获取要显示奖品
function ActiveDrawDlg:changeShowRewards(alas)
    local isChange = false
    if not self.bonusInfo then self.bonusInfo = {} end
    local curTimeStr = gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime())
    for i = 1, #BonusInfo[alas] do

        local reward = BonusInfo[alas][i][1]
        if ChangeTime[alas] and ChangeTime[alas][i] then
            for _, t in ipairs(ChangeTime[alas][i]) do
                if curTimeStr >= t.startTime and curTimeStr <= t.endTime then
                    reward = BonusInfo[alas][i][t.choose]
                    break
                end
            end
        end

        if not self.bonusInfo[i] or self.bonusInfo[i].chs ~= reward.chs then
            isChange = true
            self.bonusInfo[i] = reward
        end
    end

    return isChange
end

function ActiveDrawDlg:resetRewards()
    for i = 1, REWARD_MAX do
        local panel = self:getControl("BonusPanel_" .. i)
        self:setCtrlVisible("ChosenImage", false, panel)

        if self.bonusInfo[i].icon then
            if self.bonusInfo[i].isPlist == 1 then
                self:setImagePlist("BonusImage", self.bonusInfo[i].icon, panel)
            else
                self:setImage("BonusImage", self.bonusInfo[i].icon, panel)
            end

            local image = self:getControl("BonusImage", nil, panel)
            if self.bonusInfo[i].icon == ResMgr.ui.no_bachelor_pick then
                local sss = image:getPositionY() - 31
                image:setPositionY(sss)

                panel:requestDoLayout()
            end

        elseif self.bonusInfo[i].petPortrait then
            self:setImage("BonusImage", ResMgr:getSmallPortrait(self.bonusInfo[i].petPortrait), panel)
        elseif self.bonusInfo[i].itemIcon then
            self:setImage("BonusImage", ResMgr:getItemIconPath(self.bonusInfo[i].itemIcon), panel)
        else
            local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.bonusInfo[i].chs))
            self:setImage("BonusImage", path, panel)
        end

        self:setItemImageSize("BonusImage", panel)

        if 1 == self.bonusInfo[i].timeLimit then
            InventoryMgr:addLogoTimeLimit(self:getControl("BonusImage", Const.UIImage, panel))
        else
            InventoryMgr:removeLogoTimeLimit(self:getControl("BonusImage", Const.UIImage, panel))
        end

        self:setLabelText("NameLabel", self.bonusInfo[i].chs, panel)
    end
end

-- 开始转圈
function ActiveDrawDlg:onUpdate()
    if not self.isRotating then
        if ChangeTime[self.curLottery] and self:changeShowRewards(self.curLottery) then
            self:resetRewards()
        end

        return
    end

    if self.updateTime % self.delay ~= 0 then
        self.updateTime = self.updateTime + 1
        return
    end

    if self.curPos < self.needCount then
        -- 转五行
        self.delay = self:calcSpeed(self.curPos, self.needCount)
        local wuxPos = (self.curPos) % REWARD_MAX + 1
        local rollCtrl = self:getControl("ChosenImage", nil, "BonusPanel_" .. wuxPos)
        rollCtrl:setVisible(true)
        rollCtrl:setOpacity(255)
        self.curPos = self.curPos + 1
        if self.curPos ~= self.needCount then
            local timeT = self.delay * 0.03
            if timeT > 1 then timeT = 1 end
            rollCtrl:runAction(cc.FadeOut:create(timeT))
        else
            rollCtrl:stopAllActions()
        end
    else
        self.isRotating = false
        GiftMgr:drawActiveReward(1) -- 领奖
    end
end

-- 计算转圈间隔
function ActiveDrawDlg:calcSpeed(curPos, count)
    if count - curPos < 14 then
        local speed = 6 + (14 - (count - curPos)) * (14 - (count - curPos)) * 0.6
        return math.floor(speed)
    end

    return 6
end

function ActiveDrawDlg:onDrawButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self:isOutLimitTime("lastTime", 1000 * 10) then
        gf:ShowSmallTips(CHS[4300098])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    if self.isRotating then
        return
    end

    if Me:queryBasicInt("level") < 35 then
        gf:ShowSmallTips(CHS[4300097])
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())
    GiftMgr:drawActiveReward(0)
end

function ActiveDrawDlg:MSG_LIVENESS_LOTTERY_RESULT(data)
    local ret = -1

    -- 全套家电特殊处理
    if data.reward == CHS[5420109] then
        if self.bonusInfo[5].chs ~= CHS[5420109] then
            self.bonusInfo[5] = BonusInfo[self.curLottery][5][2]
        end
    end

    for i = 1, REWARD_MAX do
        if self.bonusInfo[i].chs == data.reward then
            ret = i + 1
            break
        end
    end

    if ret == -1 then
        -- 未找到对应奖品不做处理  WDSY-27475
        return
    end

    self.isRotating = true

    self.needCount = ret - self.startPos + math.random(4,5) * REWARD_MAX
    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1

    self:resetRewards()
end

function ActiveDrawDlg:MSG_OPEN_WELFARE(data)
    self:setLabelText("NoteLabel_1", CHS[4400002] .. data.activeCount)
    self:updateLayout("SignPanel")
end

function ActiveDrawDlg:MSG_OPEN_LIVENESS_LOTTERY(data)
    if not data.alas or not BonusInfo[data.alas] then
        return
    end

    self:changeShowRewards(data.alas)
    self:resetRewards()
    self.curLottery = data.alas
    self.activeValue = data.activeValue
    if self.activeValue then
        self:setLabelText("NoteLabel_2", string.format(CHS[4400009], self.activeValue))
    end

    self:updateLayout("WelfarePanel")
end

return ActiveDrawDlg
