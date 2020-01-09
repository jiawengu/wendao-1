-- BlogTabDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间Tab, 打开第二个

local BlogTabDlg = require('dlg/BlogTabDlg')
local BlogEXTabDlg = Singleton("BlogEXTabDlg", BlogTabDlg)

BlogEXTabDlg.dlgs = {
    BlogCircleCheckBox = "BlogCircleEXDlg",
    BlogMessageCheckBox = "BlogMessageEXDlg",
    HomeShowCheckBox = "HomeShowEXDlg",
}

function BlogEXTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end
    local name = sender:getName()
    local gid = BlogMgr:getUserGid(self.name)
    if name == "HomeShowCheckBox" and not DlgMgr:getDlgByName("HomeShowEXDlg") then
        if self.dist ~= GameMgr:getDistName() then
            gf:ShowSmallTips(CHS[4300367])
            return false
        end

        if BlogMgr:getUserGid(self.name) == Me:queryBasic("gid") then
            if Me:queryBasic("house/id") == "" then
                gf:ShowSmallTips(CHS[4200453])
            else
                HomeMgr:showHomeData(BlogMgr:getUserGid(self.name), HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
            end
        else
            HomeMgr:showHomeData(BlogMgr:getUserGid(self.name), HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
        end
        return false
    end

    if name == "BlogCircleCheckBox" and not DlgMgr:getDlgByName("BlogCircleEXDlg") then
        BlogMgr:openBlog(gid, nil, nil, BlogMgr:getDistByGid(gid))
        return false
    end

    if name == "BlogMessageCheckBox" and not DlgMgr:getDlgByName("BlogMessageEXDlg") then

        BlogMgr:requestPopularAndFlower(gid, BlogMgr:getDistByGid(gid))
        BlogMgr:openBlog(gid, 2, nil, BlogMgr:getDistByGid(gid))
        return false
    end

    return true
end


-- 派生对象中可通过重新该函数来实现共用对话框配置
function BlogEXTabDlg:getCfgFileName()
    return ResMgr:getDlgCfg("BlogTabDlg")
end


return BlogEXTabDlg
