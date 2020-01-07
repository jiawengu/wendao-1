-- PeachTreeDlg.lua
-- Created by huangz Nov/17/2017
-- 桃花树界面

local MarriageTreeDlg = require('dlg/MarriageTreeDlg')
local PeachTreeDlg = Singleton("PeachTreeDlg", MarriageTreeDlg)

function PeachTreeDlg:init()
    self:bindListener("MySignButton", self.onMySignButton)
    self:bindListener("BackToTreeButton", self.onBackToTreeButton)
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    
    self:setCtrlVisible("DelAllButton", false)

    self.paperSignPanel = self:getControl("PaperSignPanel", nil, "TreePanel")
    self.paperSignPanel:retain()
    self.paperSignPanel:removeFromParent()

    self.bamboosSignPanel = self:getControl("BamboosSignPanel", nil, "TreePanel")
    self.bamboosSignPanel:retain()
    self.bamboosSignPanel:removeFromParent()

    self.jadeSignPanel = self:getControl("JadeSignPanel", nil, "TreePanel")
    self.jadeSignPanel:retain()
    self.jadeSignPanel:removeFromParent()

    self.treePanel = self:getControl("TreePanel")
    self.treePanel:retain()
    self.treePanel:removeFromParent()

    -- 绑定数字键盘
    self:bindNumInput("PageInfoPanel", "PagePanel", self.limitCallBack, 1)

    self:bindNumInput("TextPanel", "InputPanel", nil, nil, 2)

    
    self.showPage = MarryMgr:getLastPage() -- 界面上显示的页数
    
    self.allPage = 0  -- 总页数
    
    self.showType = 1 -- 1 分页祝福签，2 我的祝福签，3 查找祝福签
    
    self.curPage = 0  -- 界面数据对应的实际页数
    self.yyqNo = ""

    self:showNumImgPage(self.showPage, self.allPage)

    self:requestOnePage(self.showPage)

    self:hookMsg("MSG_ZFQ_PAGE")
    self:hookMsg("MSG_REQUEST_MY_ZFQ_RESULT")
    self:hookMsg("MSG_SEARCH_ZFQ_RESULT")
end

function PeachTreeDlg:cleanup()
    DlgMgr:closeDlg("PeachSignDlg")
    MarriageTreeDlg.cleanup(self)
end

function PeachTreeDlg:requestOnePage(page)
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_ZFQ_PAGE", {page = page})
end

function PeachTreeDlg:requestMySign()
    DlgMgr:openDlg("WaitDlg")
    self.curPage = 0
    gf:CmdToServer("CMD_REQUEST_MY_ZFQ", {})
end

function PeachTreeDlg:requestSearchOneZFQ(no)
    gf:CmdToServer("CMD_SEARCH_ZFQ", {yyq_no = no})
end

-- 查找
function PeachTreeDlg:onSearchButton(sender, eventType)
    if not string.match(self.yyqNo, "%d+") then
        gf:ShowSmallTips(CHS[5410172])
        return
    end

    if self.allPage == 0 then
        gf:ShowSmallTips(CHS[5410173])
        return
    end

    self:requestSearchOneZFQ(self.yyqNo)
end

-- 展示祝福签内容
function PeachTreeDlg:onShowMarriageSign(sender, eventType)
    local tag = sender:getTag()
    local dlg = DlgMgr:openDlg("PeachSignDlg")
    dlg:setData(tag, self.showType)
end

-- 搜索祝福签结果
function PeachTreeDlg:MSG_SEARCH_ZFQ_RESULT(data)
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)

    local dlg = DlgMgr:openDlg("PeachSignDlg")
    dlg:setData(1, 3)
end

-- 祝福签分页数据
function PeachTreeDlg:MSG_ZFQ_PAGE(data)
    self:MSG_YYQ_PAGE(data)
end

-- 我的祝福签数据
function PeachTreeDlg:MSG_REQUEST_MY_ZFQ_RESULT(data)
    self:MSG_REQUEST_MY_YYQ_RESULT(data)
end

-- 换线流程会中断，需重新请求换线
function PeachTreeDlg:resetWaitStatus()
    if self.showPage ~= self.curPage and self.showType == 1 then
        self:requestOnePage(self.showPage)  
    end
end

return PeachTreeDlg
