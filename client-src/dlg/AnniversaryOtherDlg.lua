-- AnniversaryOtherDlg.lua
-- created by huangzz Mar/15/2017
-- 周年庆 其它精彩界面

local AnniversaryOtherDlg = Singleton("AnniversaryOtherDlg", Dialog)

function AnniversaryOtherDlg:init()
    self:bindListener("DGImage", self.onDGImage)
    self:bindListener("HBImage", self.onHBImage)
    self:bindListener("ZZImage", self.onZZImage)
end

-- 周年蛋糕
function AnniversaryOtherDlg:onDGImage(sender, eventType)
    DlgMgr:openDlgWithParam({"ActivitiesDlg", CHS[5420152] .. ":" .. CHS[7190366]})
end

-- 周年红包
function AnniversaryOtherDlg:onHBImage(sender, eventType)
    DlgMgr:openDlgWithParam({"ActivitiesDlg", CHS[5420152] .. ":" .. CHS[7100199]})
end

-- 中洲纪事
function AnniversaryOtherDlg:onZZImage(sender, eventType)
    DlgMgr:openDlgWithParam({"ActivitiesDlg", CHS[5420152] .. ":" .. CHS[7100170]})
end

return AnniversaryOtherDlg
