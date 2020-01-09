-- SevenDaysRewardDlg.lua
-- Created by songcw Feb/17/2016
-- 7天登入奖励界面

local DaysRewardDlg = require("dlg/DaysRewardDlg")
local SevenDaysRewardDlg = Singleton("SevenDaysRewardDlg", DaysRewardDlg)
local RewardContainer = require("ctrl/RewardContainer")

function SevenDaysRewardDlg:init()
    DaysRewardDlg.init(self)
    GiftMgr.lastIndex = "WelfareButton7"
    self:hookMsg("MSG_LOGIN_GIFT")
end

function SevenDaysRewardDlg:getGiftData()
    return GiftMgr:getLoginGiftData()
end

-- 请求奖励数据
function SevenDaysRewardDlg:requestRewardData()
    -- 请求礼包，更新数据信息
    GiftMgr:getSevenDaysRewardData()
end

-- 领取奖励
function SevenDaysRewardDlg:takeReward(index)
    -- 点击获取
    GiftMgr:getSevenDaysReward(index)
end

function SevenDaysRewardDlg:MSG_LOGIN_GIFT()
    if self.isInitDone then
        self:undateButtonState()
    else
        self.isInitDone = true
        self:initDataInfo()
    end
end

return SevenDaysRewardDlg
