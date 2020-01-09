-- BlogInfoDlg.lua
-- Created by sujl
-- 个人信息

local BlogInfoDlg = require('dlg/BlogInfoDlg')
local BlogInfoEXDlg = Singleton("BlogInfoEXDlg", BlogInfoDlg)

local BLOG_TAGS = require("cfg/BlogTags")
local oss = require('core/oss')

function BlogInfoEXDlg:getCfgFileName()
    return ResMgr:getDlgCfg("BlogInfoDlg")
end

function onBlogExPortraitUpload(filePath)
    DlgMgr:sendMsg("BlogInfoEXDlg", "uploadPortrait", filePath)
end

function BlogInfoEXDlg:doOpenPhoto(state)
    BlogMgr:comDoOpenPhoto(state, "onBlogExPortraitUpload")
end


return BlogInfoEXDlg
