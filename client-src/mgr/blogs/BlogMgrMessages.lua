-- BlogMgrMessages.lua
-- Created by huangzz, Sep/28/2017
-- 留言信息

BlogMgr = BlogMgr or Singleton("BlogMgr")

BlogMgr.blogMessageList = {}

local MESSAGE_LIMIT_LEVEL = 40  -- 留言、赠花的等级限制

local FLOWER_INFO = {
    [CHS[5400278]] = {name = CHS[5400278] .. CHS[5400285], icon = ResMgr.ui.blog_kangnaixin, desc = CHS[5400282]},
    [CHS[5400279]] = {name = CHS[5400279] .. CHS[5400285], icon = ResMgr.ui.blog_lanmeigui, desc = CHS[5400283]},
    [CHS[5400280]] = {name = CHS[5400280] .. CHS[5400285], icon = ResMgr.ui.blog_yujinxiang, desc = CHS[5400284]},
}

function BlogMgr:getMessageLimitLevel()
    return MESSAGE_LIMIT_LEVEL
end

function BlogMgr:getFlowerInfo()
    return FLOWER_INFO
end

-- 请求留言信息
function BlogMgr:requestBlogMessageData(message, num, gid, type, distName)
    type = type or 1
    gf:CmdToServer("CMD_BLOG_MESSAGE_VIEW", {host_gid = gid, message_iid = message.iid or "", message_time = message.time or 0, message_num = num, query_type = type, user_dist = distName})
end

-- 请求他人空间未读留言信息
function BlogMgr:requestBlogUnReadMessageData(message, num)
    gf:CmdToServer("CMD_BLOG_MESSAGE_LIST_ABOUT_ME", {last_sid = message.iid or "", num = num})
end

-- 发布留言
function BlogMgr:requestAddBlogMessage(target_gid, target_iid, msg, gid, distName, targetDist)
    gf:CmdToServer("CMD_BLOG_MESSAGE_WRITE", {host_gid = gid, target_gid = target_gid or "", target_iid = target_iid or "", msg = msg, user_dist = distName, target_dist = targetDist})
end

-- 删除留言
function BlogMgr:requestDeleteBlogMessage(message_iid, gid, distName)
    gf:CmdToServer("CMD_BLOG_MESSAGE_DELETE", {host_gid = gid, message_iid = message_iid, user_dist = distName})
end

-- 请求空间人气和鲜花数目
function BlogMgr:requestPopularAndFlower(gid, dist)
    gf:CmdToServer("CMD_BLOG_FLOWER_UPDATE", {char_gid = gid, user_dist = dist or ""})
end

function BlogMgr:clearMessageList(gid)
    self.blogMessageList[gid] = nil
end

function BlogMgr:MSG_BLOG_MESSAGE_NUM_ABOUT_ME(data)
    self.unReadMessageCount = data.count
end

function BlogMgr:setStartRequestMessage(message)
    self.startRequestMessage = message
end

-- 赠送鲜花
function BlogMgr:requestPresentFlower(type, gid)
    gf:CmdToServer("CMD_BLOG_FLOWER_PRESENT", {host_gid = gid, flower = type})
end

-- 鲜花查看
function BlogMgr:requestFlowersData(gid)
    gf:CmdToServer("CMD_BLOG_FLOWER_OPEN", {host_gid = gid})
end

-- 查看送花记录
function BlogMgr:requestFlowerNotes(note, num, gid)
    gf:CmdToServer("CMD_BLOG_FLOWER_VIEW", {host_gid = gid, note_iid = note.iid or "", note_time = note.time or 0, note_num = num})
end

function BlogMgr:MSG_BLOG_FLOWER_UPDATE(data)
    self.blogFlowerInfo = data
end

MessageMgr:regist("MSG_BLOG_MESSAGE_NUM_ABOUT_ME", BlogMgr)
MessageMgr:regist("MSG_BLOG_FLOWER_UPDATE", BlogMgr)
