-- ActiveLoginRewardDlg.lua
-- Created by huangzz Dec/19/2017
-- 活跃登录礼包界面

local LoginRewardDlg = require("dlg/LoginRewardDlg")
local ActiveLoginRewardDlg = Singleton("ActiveLoginRewardDlg", LoginRewardDlg)
local RewardContainer = require("ctrl/RewardContainer")

local CONTAINNER_TAG = 99

function ActiveLoginRewardDlg:init()
    LoginRewardDlg.init(self)
    self:hookMsg("MSG_SEVENDAY_GIFT_FLAG")
end

-- 获取奖励数据
function ActiveLoginRewardDlg:getGiftData()
    return GiftMgr:getActiveLoginGiftData()
end

-- 获取奖励数据状态
function ActiveLoginRewardDlg:getGiftFlagData()
    return GiftMgr:getActiveLoginGiftFlagData()
end

-- 请求礼包数据
function ActiveLoginRewardDlg:requestGiftData()
    -- 请求礼包，更新数据信息
    gf:CmdToServer("CMD_SEVENDAY_GIFT_LIST", {})
end

-- 领取奖励
function ActiveLoginRewardDlg:takeReward(index)
    -- 点击获取
    gf:CmdToServer("CMD_SEVENDAY_GIFT_FETCH", {day = index})
end

function ActiveLoginRewardDlg:MSG_SEVENDAY_GIFT_FLAG(data)
    self:initDataInfo(GiftMgr:getActiveLoginGiftData())
    self:undateButtonState(GiftMgr:getActiveLoginGiftFlagData())
end

function ActiveLoginRewardDlg:cleanup()
end

return ActiveLoginRewardDlg
