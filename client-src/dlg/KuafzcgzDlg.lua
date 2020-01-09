-- KuafzcgzDlg.lua
-- Created by 
-- 

local KuafzcgzDlg = Singleton("KuafzcgzDlg", Dialog)

function KuafzcgzDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
end

function KuafzcgzDlg:onSelectListView(sender, eventType)
end

return KuafzcgzDlg
