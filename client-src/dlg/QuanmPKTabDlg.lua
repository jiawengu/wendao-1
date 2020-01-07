-- QuanmPKTabDlg.lua
-- Created by yangym
-- 全民PK赛程界面

local TabDlg = require('dlg/TabDlg')
local QuanmPKTabDlg = Singleton("QuanmPKTabDlg", TabDlg)

-- 按钮与对话框的映射表
QuanmPKTabDlg.dlgs = {
    QuanmPKsjDlgCheckBox = "QuanmPKsjDlg",            -- 时间
    QuanmPKscDlgCheckBox = "QuanmPKscDlg",           -- 赛程
    QuanmPKgzDlgCheckBox = "QuanmPKgzDlg",         -- 规则  
}

function QuanmPKTabDlg:init()
    TabDlg.init(self)
end

function QuanmPKTabDlg:onSelected(sender, idx)
    if not QuanminPKMgr:isTo16MatchBegin() and sender:getName() == "QuanmPKscDlgCheckBox" then
        -- 当前尚未安排64强抽签分组，无法查看赛程
        gf:ShowSmallTips(CHS[7002201])
        self:setSelectDlg(self.lastDlg)
        return
    end
    
    TabDlg.onSelected(self, sender, idx)  
end

function QuanmPKTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "QuanmPKsjDlg"
end

return QuanmPKTabDlg