-- BlogMakeUpDlg.lua
-- Created by huangzz Feb/03/2018
-- 个人空间装饰界面

local BlogMakeUpDlg = Singleton("BlogMakeUpDlg", Dialog)

function BlogMakeUpDlg:init()
    self:hookMsg("MSG_BLOG_DECORATION_LIST")
    self:hookMsg("MSG_DECORATION_LIST")
end

function BlogMakeUpDlg:initShowPanel()
    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    local name = BlogMgr:getBlogDecorateName(gid, "blog_floor")
    self:setShowPanel(name)
end

-- 根据装饰道具名称显示
function BlogMakeUpDlg:setShowPanel(name)
    self:setCtrlVisible("StarPanel", name == CHS[5400445])
end

function BlogMakeUpDlg:onCloseButton()
    local tabDlg = DlgMgr:getDlgByName("BlogTabDlg")
    if tabDlg then
        tabDlg:onCloseButton()
    end
    
    Dialog.onCloseButton(self)
end

function BlogMakeUpDlg:MSG_BLOG_DECORATION_LIST(data)
    if data.user_gid == BlogMgr:getBlogGidByDlgName(self.name) then
        self:setShowPanel(BlogMgr:getBlogDecorateName(data.user_gid, "blog_floor"))
    end
end

-- 玩家自己更换装饰刷新
function BlogMakeUpDlg:MSG_DECORATION_LIST(data)
    local gid = Me:queryBasic("gid")
    if gid == BlogMgr:getBlogGidByDlgName(self.name) then
        self:setShowPanel(BlogMgr:getBlogDecorateName(gid, "blog_floor"))
    end
end

return BlogMakeUpDlg
