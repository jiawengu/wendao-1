-- PartyRedBagMoneyInfoDlg.lua
-- Created by zhengjh Aug/28/8
-- 抢红包记录

local PartyRedBagMoneyInfoDlg = Singleton("PartyRedBagMoneyInfoDlg", Dialog)

function PartyRedBagMoneyInfoDlg:init()
    self.rewardCell = self:getControl("RewardPanel")
    self.rewardCell:retain()
    self.rewardCell:removeFromParent()
end

function PartyRedBagMoneyInfoDlg:setData(data)
    self:setUiInfo(data)
end

function PartyRedBagMoneyInfoDlg:setUiInfo(data)
    -- 时间
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d", data.sendTime))
    
    -- 留言
    self:setLabelText("MessageLabel", data.msg)
    
    -- 红包数量
    self:setLabelText("PartyRedBagNumLabel", string.format("(%d/%d)", data.size, data.count))
    
    -- 总共元宝
    self:setLabelText("PartyRedbagTotal_1", data.totalCoin)
    self:setLabelText("PartyRedbagTotal_2", data.totalCoin)
    
    
    -- 初值化列表
    self:setListData(data.list)
    
    -- 设置自己的信息
    self:setMyInfo(data.list)  
end

function PartyRedBagMoneyInfoDlg:setListData(data)
    local count = #data

    local listView = self:getControl("PartyRedbagRewardListView")
    listView:removeAllChildren()

    for i = 1, count do
        local cell = self:createCell(data[i])
        listView:pushBackCustomItem(cell)
    end
end

function PartyRedBagMoneyInfoDlg:setMyInfo(data)
    local info = nil
	for i = 1, #data do
	   if Me:queryBasic("name") == data[i].name then
	       info = data[i]
	       break
	   end
	end
	
	if not info then
        self:setCtrlVisible("MyPartyRedbagNonePanel", true)
        self:setCtrlVisible("MyPartyRedbagRewardPanel", false)
	else
	    self:setCtrlVisible("MyPartyRedbagNonePanel", false)
	    self:setCtrlVisible("MyPartyRedbagRewardPanel", true)
	    local panel = self:getControl("MyPartyRedbagRewardPanel")
        self:setLabelText("UserNameLabel", gf:getRealName(info.name), panel)

        self:setLabelText("UserPartyRedbagRewardLabel_1", info.coin, panel)
        self:setLabelText("UserPartyRedbagRewardLabel_2", info.coin, panel)
	end
end

function PartyRedBagMoneyInfoDlg:createCell(data)
    local cell = self.rewardCell:clone()
    self:setLabelText("UserNameLabel", gf:getRealName(data.name), cell)
    
    self:setLabelText("PartyRedbagReward_1", data.coin, cell)
    self:setLabelText("PartyRedbagReward_2", data.coin, cell)
    
    self:setCtrlVisible("LuckyImage", (data.isMax == true), cell)
    
    return cell
end

function PartyRedBagMoneyInfoDlg:cleanup()
    self:releaseCloneCtrl("rewardCell")
end

return PartyRedBagMoneyInfoDlg
