-- JuBaoUserViewTabDlg.lua
-- Created by songcw Dec/14/2016
-- 聚宝斋玩家信息查看标签页

local TabDlg = require('dlg/TabDlg')
local JuBaoUserViewTabDlg = Singleton("JuBaoUserViewTabDlg", TabDlg)

JuBaoUserViewTabDlg.defDlg = "JuBaoUserViewSelfDlg"

JuBaoUserViewTabDlg.dlgs = {
    JuBaoUserViewSelfDlgCheckBox = "JuBaoUserViewSelfDlg",
    JuBaoUserViewPetDlgCheckBox = "JuBaoUserViewPetDlg",
    JuBaoUserViewGuardDlgCheckBox = "JuBaoUserViewGuardDlg",
    JuBaoUserViewBagDlgCheckBox = "JuBaoUserViewBagDlg",
    JuBaoUserViewHomeDlgCheckBox = "JuBaoUserViewHomeDlg",
}

function JuBaoUserViewTabDlg:init()
    TabDlg.init(self)
    self:setCtrlVisible("JuBaoUserViewGuardDlgCheckBox", true)
    self:setCtrlVisible("JuBaoUserViewBagDlgCheckBox", true)
    
end

-- 清理资源
function JuBaoUserViewTabDlg:cleanup()
    if not self.goods_gid then return end
    TradingMgr:cleanDataByGid(self.goods_gid)
    self.goods_gid = nil
end

function JuBaoUserViewTabDlg:setGid(gid)
    self.goods_gid = gid
end

function JuBaoUserViewTabDlg:getGid()
    return self.goods_gid
end

return JuBaoUserViewTabDlg
