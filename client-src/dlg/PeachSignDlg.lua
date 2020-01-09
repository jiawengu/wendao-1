-- PeachSignDlg.lua
-- Created by huangzz  Nov/17/2017
-- 祝福签展示界面

local MarriageSignDlg = require('dlg/MarriageSignDlg')
local PeachSignDlg = Singleton("PeachSignDlg", MarriageSignDlg)

function PeachSignDlg:init()
    self:setFullScreen()
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LikeButton", self.onLikeButton)
    self:bindListener("HateButton", self.onHateButton)
    
    self:hookMsg("MSG_ZFQ_PAGE")
    self:hookMsg("MSG_REFRESH_ZFQ_INFO")

    local bKPanel = self:getControl("BKPanel")
    local winSize = self:getWinSize()
    bKPanel:setContentSize(winSize.width / Const.UI_SCALE + winSize.ox * 2, winSize.height / Const.UI_SCALE + winSize.oy * 2)
end

function PeachSignDlg:requestOnePage(page)
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_ZFQ_PAGE", {page = page})
end

function PeachSignDlg:onLikeButton(sender, eventType)
    gf:CmdToServer("CMD_COMMENT_ZFQ", {yyq_no = self.marriageSign[self.curNum].yyq_no, oper = 1})
end

function PeachSignDlg:onHateButton(sender, eventType)
    gf:CmdToServer("CMD_COMMENT_ZFQ", {yyq_no = self.marriageSign[self.curNum].yyq_no, oper = 2})
end

function PeachSignDlg:MSG_ZFQ_PAGE(data)
    self:MSG_YYQ_PAGE(data)
end

-- 刷新单个祝福签
function PeachSignDlg:MSG_REFRESH_ZFQ_INFO(data)
    self:MSG_REFRESH_YYQ_INFO(data)
end

return PeachSignDlg
