-- AnniversaryShareDlg.lua
-- Created by lixh Api/17 2018
-- 周年庆分享界面

local AnniversaryShareDlg = Singleton("AnniversaryShareDlg", Dialog)

function AnniversaryShareDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("BKImage", "BKPanel", true)
    self:setLabelText("NameLabel", Me:getName())
    self:setLabelText("DistLabel", GameMgr:getDistName())
end

return AnniversaryShareDlg
