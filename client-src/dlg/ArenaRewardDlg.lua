-- ArenaRewardDlg.lua
-- Created by zhengjh Mar/13/2015
-- 竞技场奖励

local ArenaRewardDlg = Singleton("ArenaRewardDlg", Dialog)
local CONST_DATA =
{
    ListCellNumber = 20,
}

function ArenaRewardDlg:init()
    self:bindListViewListener("ContentListView", self.onSelectContentListView)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.rewardPanel = self:getControl("RewardPanel1", Const.UIPanel)
    self.rewardPanel:retain()

    self.listView = self:getControl("ContentListView", Const.UIListView)
    self.listView:removeAllChildren()
    self.listView:setDirection(ccui.ListViewDirection.vertical)

    self:hookMsg("MSG_ARENA_TOP_BONUS_LIST")
    self:MSG_ARENA_TOP_BONUS_LIST()
   -- ArenaMgr:getTopRewardList()
end

function ArenaRewardDlg:cleanup()
    self:releaseCloneCtrl("rewardPanel")
end

function ArenaRewardDlg:MSG_ARENA_TOP_BONUS_LIST()
    self:initList()
end

function ArenaRewardDlg:initList()
    self.rewardList = ArenaMgr:getHighestRewardList()
    local highestRankLabel = self:getControl("HighestRankingAtlasLabel", Const.UIAtlasLabel)
    highestRankLabel:setString(self.rewardList["highestRank"])
    self.listView:removeAllChildren()

    for i = 1, #self.rewardList do
        local cell = self.rewardPanel:clone()
        self:setcellInfo(cell, i)
        ccui.ListView.pushBackCustomItem(self.listView, cell)
    end

    -- 找到第一个 不是已领取状态
    local scrollNumber  = self:getScrollToNumber(self.rewardList)

    performWithDelay(self.listView, function()
    local prencent = (scrollNumber * self.rewardPanel:getContentSize().height) / (self.listView:getInnerContainer():getContentSize().height - self.listView:getContentSize().height)

    if prencent > 1 then
        prencent = 1
    end

    self.listView:scrollToPercentVertical(100 * prencent, 0.5, true)
    end, 0.01)
end

function ArenaRewardDlg:getScrollToNumber(rewardList)
    local scrollToNumber = 1

    for i = 1,#rewardList do
        if rewardList[i]["status"] ~= 2 then  -- 第一个不是已领取
            scrollToNumber = i
            break
        end
    end

    if scrollToNumber - 2 < 0 then  -- 要滑动到第一个不是已领取的前一个
        return 0
    else
        return scrollToNumber - 2
    end
end

function ArenaRewardDlg:setcellInfo(cell, tag)
    -- 达到的条件
    local rankLabel = self:getControl("LimitLabel", Const.UILabel, cell)
    rankLabel:setString(string.format(CHS[6000131], self.rewardList[tag]["rank"]))

    -- 奖励
    local rewardLabel = self:getControl("GoldLabel", Const.UILabel, cell)
    rewardLabel:setString(self.rewardList[tag]["bonus"])

    -- 领取状态
    local getBtn = self:getControl("GetButton", Const.UIButton, cell)
    getBtn:setTag(tag)
    local gotBtn = self:getControl("GotButton", Const.UIButton, cell)
    local noBtn = self:getControl("NoButton", Const.UIButton, cell)
    self:bindListener("GetButton", self.onGetButton, cell)

    if self.rewardList[tag]["status"] == 0 then     -- 未达成
        getBtn:setVisible(false)
        noBtn:setVisible(true)
        gf:grayImageView(noBtn)
    elseif self.rewardList[tag]["status"] == 1 then -- 未领取
        getBtn:setVisible(true)
        noBtn:setVisible(false)
    elseif self.rewardList[tag]["status"] == 2 then --已领取
        getBtn:setVisible(false)
        gotBtn:setVisible(true)
        gf:grayImageView(gotBtn)
    end

end

function ArenaRewardDlg:onGetButton(sender, eventType)
    local tag = sender:getTag()
    ArenaMgr:getReward(self.rewardList[tag]["rank"])
end

function ArenaRewardDlg:onConfirmButton()
    DlgMgr:closeDlg(self.name)
end

function ArenaRewardDlg:onSelectContentListView(sender, eventType)
end

return ArenaRewardDlg
