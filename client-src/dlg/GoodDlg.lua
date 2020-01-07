-- GoodDlg.lua
-- Created by zhengjh Jan/18/2016
-- 好心值悬浮框

local GoodDlg = Singleton("GoodDlg", Dialog)

function GoodDlg:init()
    self:bindListener("GoToButton", self.onGoToButton)
    self:setCanGetGoodValue()
end

-- 设置可获取的好心值
function GoodDlg:setCanGetGoodValue()
    self:setLabelText("GetPointLabel_1", Me:queryInt("fetch_nice"))
end

function GoodDlg:onGoToButton(sender, eventType)
    local decStr = CHS[3002729]
    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    DlgMgr:closeDlg("UserDlg")
    DlgMgr:closeDlg(self.name)
end

return GoodDlg
