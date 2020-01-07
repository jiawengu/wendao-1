-- ZhiDuoXingInfoDlg.lua
-- Created by huangzz Oct/23/2017
-- 帮派智多星规则说明界面

local ZhiDuoXingInfoDlg = Singleton("ZhiDuoXingInfoDlg", Dialog)

function ZhiDuoXingInfoDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ZhiDuoXingInfoPanel", self.onCloseButton)
end

function ZhiDuoXingInfoDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ZhiDuoXingRuleDlg")
    self:onCloseButton()
end

return ZhiDuoXingInfoDlg
