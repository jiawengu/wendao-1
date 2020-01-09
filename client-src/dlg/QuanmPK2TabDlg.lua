-- QuanmPK2TabDlg.lua
-- Created by lixh Jul/16 2018
-- 全民PK第2版菜单界面

local TabDlg = require('dlg/TabDlg')
local QuanmPK2TabDlg = Singleton("QuanmPK2TabDlg", TabDlg)

-- 按钮与对话框的映射表
QuanmPK2TabDlg.dlgs = {
    QuanmPK2sjDlgCheckBox = "QuanmPK2sjDlg",    -- 时间
    QuanmPK2jfDlgCheckBox = "QuanmPK2jfDlg",    -- 积分  
    QuanmPK2scDlgCheckBox = "QuanmPK2scDlg",    -- 赛程
    QuanmPK2fxDlgCheckBox = "QuanmPK2fxDlg",    -- 分享  
}

function QuanmPK2TabDlg:init()
    TabDlg.init(self)
end

function QuanmPK2TabDlg:onSelected(sender, idx)
    if sender:getName() == "QuanmPK2scDlgCheckBox" then
        if not DlgMgr:getDlgByName("QuanmPK2scDlg") then
            self:setSelectDlg(self.lastDlg)
        end

        QuanminPK2Mgr:requestQmpkScInfo()
        return
    end

    if sender:getName() == "QuanmPK2fxDlgCheckBox" then
        if not QuanminPK2Mgr:isMeCityTeam() then
            if not QuanminPK2Mgr:isMeSignUp() then
                -- 你未报名参加全民PK赛，无法分享。
                gf:ShowSmallTips(CHS[7100293])
                self:setSelectDlg(self.lastDlg)
                return
            elseif not QuanminPK2Mgr:isMeEnsureTeam() then
                -- 你未及时确认参赛队伍阵容，已失去参赛资格，无法分享。
                gf:ShowSmallTips(CHS[7100294])
                self:setSelectDlg(self.lastDlg)
                return
            elseif not QuanminPK2Mgr:isStartScoreCompet() then
                -- 正式比赛尚未开始，无法分享。
                gf:ShowSmallTips(CHS[7100292])
                self:setSelectDlg(self.lastDlg)
                return
            end
        else
            -- 城市赛队伍
            if not QuanminPK2Mgr:isStartTaotaiCompet() then
                -- 正式比赛尚未开始，无法分享。 城市赛要等淘汰赛队伍开始
                gf:ShowSmallTips(CHS[7100292])
                self:setSelectDlg(self.lastDlg)
                return
            end
        end
    end

    TabDlg.onSelected(self, sender, idx)  
end

function QuanmPK2TabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "QuanmPK2sjDlg"
end

return QuanmPK2TabDlg
