-- BlogMgr_Circle.lua
-- created by song Sep/20/2017
-- 朋友圈

BlogMgr = BlogMgr or Singleton("BlogMgr")

-- BlogMgr.circleOpenInitData说明
-- 与李锦龙确认 MSG_BLOG_REQUEST_STATUS_LIST 和 MSG_BLOG_OPEN_BLOG 无法确认先后关系
-- circleOpenInitData表示开启界面时，服务器下发的初始数据
-- 一切动机为了打开界面时，已经有数据，避免闪一下
BlogMgr.circleOpenInitData = {}

BlogMgr.orgPicturePath = {}

BlogMgr.PHOTO_SMALL_SIZE_STR = "image/resize,w_144"

-- 记录gid对应的区组
BlogMgr.GID_MAPS = {
}

function BlogMgr:cleanupCircle()
    BlogMgr.GID_MAPS = { }
end

-- 协议
function BlogMgr:agreement()
    gf:CmdToServer('CMD_BLOG_AGREE_STATUS_AGREEMENT')
end

-- 请求某条状态的所有点赞玩家
function BlogMgr:queryStatusLikeList(sid, distName)
    distName = distName or GameMgr:getDistName()
    gf:CmdToServer('CMD_BLOG_REQUEST_LIKE_LIST', { sid = sid, user_dist = distName})
end

-- 举报某个动态
function BlogMgr:reportStatus(uid, sid, user_dist)
    gf:CmdToServer('CMD_BLOG_REPORT_ONE_STATUS', { uid = uid, sid = sid, user_dist = user_dist})
end

-- 发表状态
function BlogMgr:publishStatus(text, img_str, viewType)
    gf:CmdToServer('CMD_BLOG_PUBLISH_ONE_STATUS', { text = text, img_str = img_str, viewType = viewType})
end

-- 删除评论     isExpand:是否展开评论，评论是否展开，表现形式不一致
function BlogMgr:deleteComment(sid, cid, isExpand, user_dist)
    gf:CmdToServer('CMD_BLOG_DELETE_ONE_COMMENT', { sid = sid, cid = cid, isExpand = isExpand , user_dist = user_dist})
end

-- 删除状态
function BlogMgr:deleteStatus(sid)
    gf:CmdToServer('CMD_BLOG_DELETE_ONE_STATUS', { sid = sid })
end

-- 点赞
function BlogMgr:likeStatusById(sid, distName, uid)
    gf:CmdToServer('CMD_BLOG_LIKE_ONE_STATUS', { sid = sid, user_dist = distName, uid = uid})
end

-- 请求所有评论数据
function BlogMgr:queryAllComment(sid, user_dist)
    gf:CmdToServer('CMD_BLOG_ALL_COMMENT_LIST', { sid = sid, user_dist = user_dist })
end

-- 评论
function BlogMgr:publishComment(uid, sid, reply_cid, reply_gid, reply_dist, text, is_expand, status_dist)
    reply_cid = reply_cid or 0
    reply_gid = reply_gid or ""
    reply_dist = reply_dist or ""
    is_expand = is_expand or 0

    gf:CmdToServer('CMD_BLOG_PUBLISH_ONE_COMMENT', { uid = uid, sid = sid,
        reply_cid = reply_cid, reply_gid = reply_gid, reply_dist = reply_dist,
        text = text, is_expand = is_expand, status_dist = status_dist})
end

-- 请求状态列表 user_gid：对象gid， last_sid当前最后一条动态id， viewType 当前请求状态，0表示看所有人动态，1表示看自己状态
function BlogMgr:queryBlogsList(user_gid, last_sid, viewType)
    last_sid = last_sid or ""
    local distName = BlogMgr:getDistByGid(user_gid)
    gf:CmdToServer('CMD_BLOG_REQUEST_STATUS_LIST', { user_gid = user_gid, last_sid = last_sid , viewType = viewType, user_dist = distName})
end

function BlogMgr:queryUnReadStatusList(last_sid)
    last_sid = last_sid or ""
    gf:CmdToServer('CMD_BLOG_STATUS_LIST_ABOUT_ME', {last_sid = last_sid})
end

-- 请求切换个人空间状态 type: 0表示查看所有人的状态  1表示查看自己的状态
function BlogMgr:switchViewSetting(type)
    gf:CmdToServer('CMD_BLOG_SWITCH_VIEW_SETTING', { type = type })
end

--
function BlogMgr:queryUnReadData()
    gf:CmdToServer('CMD_BLOG_REQUEST_UNREAD_DATA', {})
end

function BlogMgr:MSG_BLOG_CHAR_INFO(data)
    self.userInfo[data.user_gid] = data
    local brothers = data.brothers
    if brothers and #brothers > 0 then
        JiebaiMgr:insertChengWeiByData(brothers, data.user_gid)
    end

    -- 检测是否能打开界面
    self:checkDataOpenDlg(data.user_gid, data, "MSG_BLOG_CHAR_INFO")

    -- 刷新同城社交的自定义头像数据
    if data.user_gid == Me:queryBasic("gid") then
        CitySocialMgr:MSG_LBS_BLOG_ICON_IMG({
            icon_img = data.icon_img,
            under_review = data.under_review
        })
    end
end

-- MSG_BLOG_CHAR_INFO\MSG_BLOG_OPEN_BLOG\MSG_BLOG_REQUEST_STATUS_LIST与服务器确认，收到顺序都不能肯定！！！
function BlogMgr:MSG_BLOG_OPEN_BLOG(data)

    self.GID_MAPS[data.gid] = data.user_dist

    if self.userInfo[data.gid] then
        self.userInfo[data.gid].user_gid = data.gid
    else
        self.userInfo[data.gid] = {}
        self.userInfo[data.gid].user_gid = data.gid
    end

    if data.openType == 2 then
        -- 留言板
        self:openBlogDlg(data.gid, "BlogMessage", self.userInfo[data.gid])
    else
        self:checkDataOpenDlg(data.gid, data, "MSG_BLOG_OPEN_BLOG")
    end
end


function BlogMgr:MSG_BLOG_REQUEST_STATUS_LIST(data)
    -- 客户端最后关心的打开gid和服务器下发的不一致。不处理
    if data.uid ~= self.openGid then return end

    self:checkDataOpenDlg(data.uid, data, "MSG_BLOG_REQUEST_STATUS_LIST")
end

function BlogMgr:MSG_BLOG_STATUS_NUM_ABOUT_ME(data)
    self.unReadStatueCount = data.count
end

function BlogMgr:openBlogDlg(gid, subDlgName, data)
    local tabExDlg = DlgMgr:getDlgByName("BlogEXTabDlg")
    local dlgNameEx = subDlgName .. "EXDlg"
    local dlgName = subDlgName .. "Dlg"
    if tabExDlg then
        -- 如果第二层已经打开了
        -- 这个时候要判断第一层空间和要打开的空间是否相同，相同则关闭第二层就好
        local tabDlg = DlgMgr:getDlgByName("BlogTabDlg")
        if tabDlg and tabDlg:getUserGid() == gid then
            DlgMgr:closeTabDlg("BlogEXTabDlg")
        elseif tabExDlg:getCurSelect() ~= dlgNameEx or tabExDlg:getUserGid() ~= gid then
            -- 覆盖第二层
            DlgMgr:closeDlg(dlgNameEx, "BlogEXTabDlg")
            DlgMgr:openDlgEx(dlgNameEx, data)
            DlgMgr:sendMsg("BlogEXTabDlg", "setUserGid", gid, BlogMgr.GID_MAPS[gid])
        end
    else
        local dlg = DlgMgr:getDlgByName("BlogTabDlg")
        if dlg and dlg:getUserGid() ~= gid then
            -- 第一个已经打开了，打开第二个
            DlgMgr:openDlgEx(dlgNameEx, data)
            DlgMgr:sendMsg("BlogEXTabDlg", "setUserGid", gid, BlogMgr.GID_MAPS[gid])
        else
            if not dlg or dlg:getCurSelect() ~= dlgName then
                -- 正常打开第一个就好
                DlgMgr:openDlgEx(dlgName, data)
                DlgMgr:sendMsg("BlogTabDlg", "setUserGid", gid, BlogMgr.GID_MAPS[gid])
            end
        end
    end
end

-- 检测3个消息是否已经收到
function BlogMgr:checkDataOpenDlg(gid, data, dataType)
    if not BlogMgr.circleOpenInitData[gid] then BlogMgr.circleOpenInitData[gid] = {} end
    BlogMgr.circleOpenInitData[gid][dataType] = data

    if BlogMgr.circleOpenInitData[gid]["MSG_BLOG_REQUEST_STATUS_LIST"]
        and BlogMgr.circleOpenInitData[gid]["MSG_BLOG_OPEN_BLOG"]
        and BlogMgr.circleOpenInitData[gid]["MSG_BLOG_CHAR_INFO"] then

        local initData = BlogMgr.circleOpenInitData[gid]["MSG_BLOG_REQUEST_STATUS_LIST"]
        self:openBlogDlg(gid, "BlogCircle", initData)

        DlgMgr:sendMsg("BlogCircleDlg", "setMyBlog")
        DlgMgr:sendMsg("BlogCircleEXDlg", "setMyBlog")

        if "function" == type(BlogMgr.callBackAfterOpen) then
            BlogMgr.callBackAfterOpen()
        end

        BlogMgr.circleOpenInitData[gid]["MSG_BLOG_OPEN_BLOG"] = nil

        return true
    end
end

-- 打开时初始数据
function BlogMgr:getOpenInitData()
    local user_gid = BlogMgr:getUserGid()

    if BlogMgr.circleOpenInitData and BlogMgr.circleOpenInitData[user_gid] then
        return BlogMgr.circleOpenInitData[user_gid]["MSG_BLOG_REQUEST_STATUS_LIST"]
    end
end

-- 获取对应界面的gid
function BlogMgr:getBlogGidByDlgName(dName)
    local tabDlg = DlgMgr:getDlgByName("BlogTabDlg")
    if string.match(dName, "EX") then
        tabDlg = DlgMgr:getDlgByName("BlogEXTabDlg")
    end

    if tabDlg then
        return tabDlg:getUserGid()
    end
end

function BlogMgr:getDistByGid(gid)
    return BlogMgr.GID_MAPS[gid]
end

function BlogMgr:isSameDist(gid)
    -- 没有数据，默认为同区
    if not BlogMgr.GID_MAPS[gid] or BlogMgr.GID_MAPS[gid] == "" then
        return true
    end

    return BlogMgr.GID_MAPS[gid] == GameMgr:getDistName()
end

function BlogMgr:sendMsgToMyBlogCircleDlg(funcName, ...)
    local tabDlg = DlgMgr:getDlgByName("BlogTabDlg")
    if tabDlg and tabDlg:getUserGid() == Me:queryBasic("gid") then
        return DlgMgr:sendMsg("BlogCircleDlg", funcName, ...)
    end

    local tabDlg = DlgMgr:getDlgByName("BlogEXTabDlg")
    if tabDlg and tabDlg:getUserGid() == Me:queryBasic("gid") then
        return DlgMgr:sendMsg("BlogCircleEXDlg", funcName, ...)
    end
end

function BlogMgr:MSG_CROSS_SERVER_CHAR_INFO(data)
    self.unReadStatueCount = data.count
    self.GID_MAPS[data.gid] = data.dist_name
end

MessageMgr:regist("MSG_CROSS_SERVER_CHAR_INFO", BlogMgr)
MessageMgr:regist("MSG_BLOG_STATUS_NUM_ABOUT_ME", BlogMgr)
MessageMgr:regist("MSG_BLOG_CHAR_INFO", BlogMgr)
MessageMgr:regist("MSG_BLOG_OPEN_BLOG", BlogMgr)
MessageMgr:regist("MSG_BLOG_REQUEST_STATUS_LIST", BlogMgr)