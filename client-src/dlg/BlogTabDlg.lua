-- BlogTabDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间Tab

local TabDlg = require('dlg/TabDlg')
local BlogTabDlg = Singleton("BlogTabDlg", TabDlg)

BlogTabDlg.dlgs = {
    BlogCircleCheckBox = "BlogCircleDlg",
    BlogMessageCheckBox = "BlogMessageDlg",
    HomeShowCheckBox = "HomeShowDlg",
}

function BlogTabDlg:init()
    TabDlg.init(self)

    performWithDelay(self.root, function()
        -- 由于该部分逻辑需求在只在打开 BlogTabDlg 时才执行
        -- self.gid 要在打开 BlogTabDlg 后同帧调用 setUserGid(gid) 时才会赋值
        -- 故延时一帧处理
        if self.gid == Me:queryBasic("gid") then
            BlogMgr:queryUnReadData()


            -- 打开自己的空间检查
            -- 直接将消息显示在控件上，不加入小红点管理器的缓存中
            if BlogMgr.hasRedDotForMessage then
                self:addRedDot("BlogMessageCheckBox")
                BlogMgr:setHasMailRedDotForMessage(nil, "unread")
            end

            if BlogMgr.hasRedDotForCircle then
                self:addRedDot("BlogCircleCheckBox")
                BlogMgr:setHasMailRedDotForCircle(nil)
            end
        end
    end, 0)
end

function BlogTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end
    local name = sender:getName()
    local gid = BlogMgr:getUserGid(self.name)
    if name == "HomeShowCheckBox" and not DlgMgr:getDlgByName("HomeShowDlg") then
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

    if name == "BlogCircleCheckBox" and not DlgMgr:getDlgByName("BlogCircleDlg") then
        BlogMgr:openBlog(gid, nil, nil, BlogMgr:getDistByGid(gid))
        return false
    end

    if name == "BlogMessageCheckBox" and not DlgMgr:getDlgByName("BlogMessageDlg") then
        BlogMgr:requestPopularAndFlower(gid, BlogMgr:getDistByGid(gid))
        BlogMgr:openBlog(gid, 2, nil, BlogMgr:getDistByGid(gid))
        return false
    end

    return true
end

function BlogTabDlg:setUserGid(gid, dist)
    self.dist = dist
    self.gid = gid

    -- 由于打开界面顺序，BlogInfoDlg打开后，是获取不到这个gid的，重新刷新下
    DlgMgr:sendMsg("BlogInfoDlg", "refreshShowPanel")
    DlgMgr:sendMsg("BlogInfoEXDlg", "refreshShowPanel")

    if string.match(self.name, "EX") then
        DlgMgr:sendMsg("BlogMakeUpEXDlg", "initShowPanel")
    else
        DlgMgr:sendMsg("BlogMakeUpDlg", "initShowPanel")
    end
end

function BlogTabDlg:getUserGid()
    return self.gid
end

function BlogTabDlg:onCheckAddRedDot(ctrlName)
    if self:getCurSelectCtrlName() == ctrlName then
        return false
    end

    return true
end

function BlogTabDlg:cleanup()
    self.gid = nil
    self.dist = nil
    BlogMgr:judgeAddRedDotForBlog()

    if self.gid == Me:queryBasic("gid") then
        -- 清空未读消息
        BlogMgr:clearUnReadNum()
    end
end

return BlogTabDlg
