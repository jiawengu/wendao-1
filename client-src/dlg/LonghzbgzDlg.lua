-- LonghzbgzDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗规则说明界面

local LonghzbgzDlg = Singleton("LonghzbgzDlg", Dialog)

function LonghzbgzDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
end

function LonghzbgzDlg:onSelectListView(sender, eventType)
end

return LonghzbgzDlg
