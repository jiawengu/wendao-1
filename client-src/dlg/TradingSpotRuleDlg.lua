-- TradingSpotRuleDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站规则界面

local TradingSpotRuleDlg = Singleton("TradingSpotRuleDlg", Dialog)

function TradingSpotRuleDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
end

function TradingSpotRuleDlg:onSelectListView(sender, eventType)
end

return TradingSpotRuleDlg
