-- MergeLoginGiftDlg.lua

local LoginRewardDlg = require("dlg/LoginRewardDlg")
local MergeLoginGiftDlg = Singleton("MergeLoginGiftDlg", LoginRewardDlg)
local RewardContainer = require("ctrl/RewardContainer")

function MergeLoginGiftDlg:init()
    LoginRewardDlg.init(self)
    GiftMgr.lastIndex = "WelfareButton23"
    self:hookMsg("MSG_MERGE_LOGIN_GIFT_LIST")
end

function MergeLoginGiftDlg:getGiftData()
    return GiftMgr:getMergeLoginGiftData()
end

-- 获取奖励数据状态
function LoginRewardDlg:getGiftFlagData()
    return GiftMgr:getMergeLoginGiftData()
end

-- 请求奖励数据
function MergeLoginGiftDlg:requestGiftData()
    GiftMgr:requestMergeLoginGiftData()
end

function MergeLoginGiftDlg:takeReward(index)
    GiftMgr:getMergeLoginGift(index)
end

function MergeLoginGiftDlg:MSG_MERGE_LOGIN_GIFT_LIST()
    self:initDataInfo(self:getGiftData())
    self:undateButtonState(self:getGiftFlagData())
end

return MergeLoginGiftDlg
