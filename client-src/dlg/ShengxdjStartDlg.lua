-- ShengxdjgzDlg.lua
-- Created by songcw Feb/20/2019
-- 生肖对决开始界面
-- 同一个json ShengxdjgzDlg ，这个多一个开始按钮

local ShengxdjStartDlg = Singleton("ShengxdjStartDlg", Dialog)

function ShengxdjStartDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ShengxdjgzDlg")
end

function ShengxdjStartDlg:init()
    self:bindListener("GoButton", self.onGoButton)

    self:setCtrlVisible("GoButton", true)

    DlgMgr:sendMsg("ShengxdjDlg ", "onClickReady")
end

function ShengxdjStartDlg:onGoButton(sender, eventType)
    gf:CmdToServer("CMD_SUMMER_2019_SXDJ_PREPARE")
    self:onCloseButton()
end

return ShengxdjStartDlg
