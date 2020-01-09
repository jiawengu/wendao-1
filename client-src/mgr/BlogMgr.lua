-- BlogMgr.lua
-- created by song Sep/20/2017
-- 个人空间管理器

BlogMgr = Singleton()
local oss = require("core/oss")
local ossCfg = require("cfg/OSSCfg")

local STORE_TIME = 5 * 24 * 3600

local BUCKET = ossCfg.OSS_BUCKET or 'atm-image'
local ENDPOINT = ossCfg.OSS_ENDPOINT or 'leiting.com'
local UPLOAD_PAGE = ossCfg.OSS_UPLOAD_PAGE


-- autoLoadSmallPicturies、autoLoadBigPicturies缩略图、原图自动下载队列
-- 注意：按对话框名称区分
-- 当前规则，每次完成后，先检查原图autoLoadBigPicturies中是否有需求，没有再下载缩略图autoLoadBigPicturies
BlogMgr.autoLoadSmallPicturies = {}

-- 注册子模块{ init = function(), clear = function(), ... }
function BlogMgr:regSub(item)
    if not self.subs then self.subs = {} end
    table.insert(self.subs, item)
end

-- 初始化模块
function BlogMgr:init()
    if self.subs and #(self.subs) > 0 then
        for i = 1, #(self.subs) do
            local initFunc = self.subs[i].init
            if 'function' == type(initFunc) then
                initFunc(self)
            end
        end
    end

    self:preProcess()
end

-- 清理数据
function BlogMgr:clearData()
    if self.subs and #(self.subs) > 0 then
        for i = 1, #(self.subs) do
            local clearFunc = self.subs[i].clear
            if 'function' == type(clearFunc) then
                clearFunc(self)
            end
        end
    end

    self.uploadReq = {}
    self.queryCookie = {}
    self.requestAuths = nil
end

-- 预处理文件
function BlogMgr:preProcess()
    local data = DataBaseMgr:selectItems("blogFiles")
    for i = 1, data.count do
        local sdata = data[i]
        local time = tonumber(sdata.time)
        if not time or os.time() - time > STORE_TIME then
            self:deleteFile(sdata.name)
        end
    end
end

-- 删除文件
function BlogMgr:deleteFile(objectName)
    if string.isNilOrEmpty(objectName) then return end
    local filePath = ResMgr:getBlogPath(objectName)
    filePath = cc.FileUtils:getInstance():getWritablePath() .. filePath
    os.remove(filePath)
end

-- 调用 java 函数
local callJavaFun = function(className, fun, sig, args)
    local luaj = require('luaj')
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        Log:E("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 获取头像裁剪框大小
function BlogMgr:getPortraitClipRange()
    return gf:getPortraitClipRange(32, 32)
end

-- 状态图片裁剪大小
function BlogMgr:getPhotoClipRange()
    return gf:getPortraitClipRange(36, 24)
end

-- 状态图片缩放大小
-- w1, h1：限制大小
-- w2, h2: 图片实际大小
function BlogMgr:getPhotoScaleSize(w1, h1, w2, h2)
    if w2 / h2 >= w1 / h1 then
        if w2 > w1 then
            return { width = w1, height = math.ceil(h2 * (w1 / w2)) }
        else
            return { width = w2, height = h2 }
        end
    else
        if h2 > h1 then
            return { width = math.ceil(w2 * (h1 / h2)), height = h1 }
        else
            return { width = w2, height = h2 }
        end
    end
end

-- 访问文件
function BlogMgr:accessFile(objectName, options)
    local name
    if options and options.process then
        name = string.format("%s_%s.%s", gf:getFileName(objectName), gfGetMd5(options.process), gf:getFileExt(objectName))
    else
        name = objectName
    end
    local data = DataBaseMgr:selectItems("blogFiles", string.format("`name`='%s'", name))
    if data.count <= 0 then
        DataBaseMgr:insertItem("blogFiles", { name = name, time = os.time() })
    else
        DataBaseMgr:updateItem("blogFiles", string.format("`time`=%d", os.time()), string.format("`name`='%s'", name))
    end
end

-- 打开空间
-- openType 1 打开朋友圈  2 打开留言板
function BlogMgr:openBlog(gid, openType, callBackAfterOpen, distName)
    if not DistMgr:checkCrossDist() then return end

    gid = gid or Me:queryBasic("gid")
    distName = distName or GameMgr:getDistName()

    -- 请求个人空间的装饰信息
    gf:CmdToServer("CMD_BLOG_DECORATION_LIST", {user_gid = gid, user_dist = distName})

    gf:CmdToServer('CMD_BLOG_OPEN_BLOG', { user_gid = gid, openType = openType or 1 , user_dist = distName})

    BlogMgr.openGid = gid
    BlogMgr.circleOpenInitData[gid] = {}
    BlogMgr.callBackAfterOpen = callBackAfterOpen
    BlogMgr:setStartRequestMessage(nil)
end

function BlogMgr:setHasMailRedDotForBlog(id, reason)
    if id == 51 then
        self:setHasMailRedDotForMessage(true, reason)
    elseif id == 53 then
        self:setHasMailRedDotForCircle(true)
    end
end

-- reason   "unread" 他人空间有未读的回复留言，"" 自己空间有新留言
function BlogMgr:setHasMailRedDotForMessage(hasRedDot, reason)
    if not self.hasRedDotForMessage then
        self.hasRedDotForMessage = {}
    end

    reason = reason or ""
    self.hasRedDotForMessage[reason] = hasRedDot

    if not next(self.hasRedDotForMessage) then
        self.hasRedDotForMessage = nil
    end
end

function BlogMgr:setHasMailRedDotForCircle(hasRedDot)
    self.hasRedDotForCircle = hasRedDot
end

-- 处理关闭界面后是否要加小红点
function BlogMgr:judgeAddRedDotForBlog()
    if self.hasRedDotForMessage or self.hasRedDotForCircle then
        -- 延缓一帧等界面完全关闭再添加小红点，否则小红点会添加失败
        performWithDelay(gf:getUILayer(), function()
            RedDotMgr:insertOneRedDot("FriendDlg", "BlogDlgButton")
            RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
        end, 0)
    end
end

function BlogMgr:clearUnReadNum()
    if self.unReadMessageCount and self.unReadMessageCount > 0 then
        self:setHasMailRedDotForMessage(nil, "unread")
    end

    if self.unReadStatueCount and self.unReadStatueCount > 0 then
        self:setHasMailRedDotForCircle(nil)
    end

    self.unReadMessageCount = 0
    self.unReadStatueCount = 0
end

function BlogMgr:showButtonList(root, sender, typeStr, dlgName, param)
    local dlg = DlgMgr:openDlgEx("BlogButtonListDlg", {typeStr = typeStr, dlgName = dlgName, sender = sender, param = param}, nil, true)
    if dlg and sender then
        local rect = root:getBoundingBoxInWorldSpace(sender)
        dlg:setFloatingFramePos(rect)
        dlg:setCallbackObj(sender)
    end

    return dlg
end

function BlogMgr:removeByObjectName(dlgName, objectName)
    -- 增加容错处理，怕换线什么清空列表，然后来了
    if BlogMgr.autoLoadSmallPicturies[dlgName] and next(BlogMgr.autoLoadSmallPicturies[dlgName]) then
        for i = #BlogMgr.autoLoadSmallPicturies[dlgName], 1, -1 do
            if BlogMgr.autoLoadSmallPicturies[dlgName][i].objectName == objectName then
                table.remove(BlogMgr.autoLoadSmallPicturies[dlgName], i)
            end
        end
    end
end

function BlogMgr:pushInAutoLoad(callback, dlgName, objectName, options, para)
    -- 放进缩略图
    if not BlogMgr.autoLoadSmallPicturies[dlgName] then BlogMgr.autoLoadSmallPicturies[dlgName] = {} end
    local uFile = {callback = callback, dlgName = dlgName, objectName = objectName, options = options, para = para}
    table.insert(BlogMgr.autoLoadSmallPicturies[dlgName], uFile)
end

-- 检查文件是否存在及有效
function BlogMgr:checkFileValid(objectName, options)
    local filePath
    filePath = ResMgr:getBlogPath(objectName, options and options.process)
    local fullPath = cc.FileUtils:getInstance():getWritablePath() .. filePath
    local name
    if options and options.process then
        name = string.format("%s_%s.%s", gf:getFileName(objectName), gfGetMd5(options.process), gf:getFileExt(objectName))
    else
        name = objectName
    end
    local data = DataBaseMgr:selectItems("blogFiles", string.format("`name`='%s'", name))
    local oss = require("core/oss")
    return oss:checkFileValidity(fullPath) and data.count > 0
end

-- 确保文件存在           isForce表示直接请求，不用管队列，只会在一次请求结束后赋值true
function BlogMgr:assureFile(callback, dlgName, objectName, options, para, isForce)
    -- 该对话框要是关闭了，则清空队列中，该对话框的请求。延迟请求可能会出现该问题，防止万一
    if not DlgMgr:getDlgByName(dlgName) then
        BlogMgr.autoLoadSmallPicturies[dlgName] = nil
        return
    end

    -- 先检查本地是否存在
    local filePath
    filePath = ResMgr:getBlogPath(objectName, options and options.process)
    if self:checkFileValid(objectName, options) then
        -- 本地已经存在
        local fullPath = cc.FileUtils:getInstance():getWritablePath() .. filePath
        DlgMgr:sendMsg(dlgName, callback, fullPath, para, objectName)
        self:accessFile(objectName, options)
    else
        local function toUrlget(callback, dlgName, objectName, options, para)
            local root = DlgMgr:getDlgByName(dlgName).root
            local o = root:getChildByName("ali-oss")
            if not o then
                o = oss.new({ bucket = BUCKET, authorizationServer = function(o) self:requestAuthorization(dlgName, o) end, endpoint = ENDPOINT })
                o:setName("ali-oss")
                root:addChild(o)
            end
            o:urlgetex(function(path)
                -- 请求结果回来了
                DlgMgr:sendMsg(dlgName, callback, path, para, objectName)

                if not string.isNilOrEmpty(path) then
                    self:accessFile(objectName, options)
                end

                -- 回来时，对话框不在，则清空，增加容错，怕其他地方清空
                if not DlgMgr:getDlgByName(dlgName) then
                    BlogMgr.autoLoadSmallPicturies[dlgName] = nil
                else

                    BlogMgr:removeByObjectName(dlgName, objectName)

                    -- 可以请求下一个
                    if BlogMgr.autoLoadSmallPicturies[dlgName] and next(BlogMgr.autoLoadSmallPicturies[dlgName]) then
                        local uInfo = BlogMgr.autoLoadSmallPicturies[dlgName][1]
                        BlogMgr:assureFile(uInfo.callback, uInfo.dlgName, uInfo.objectName, uInfo.options, uInfo.para, true)
                    end
                end
            end, objectName, filePath, options)
        end

        -- 不存在，缓存中是否有原图，有则设置原图
        local orgPath
        for i = 1, 4 do
            if BlogMgr.orgPicturePath[i] and BlogMgr.orgPicturePath[i].key == objectName then
                orgPath = BlogMgr.orgPicturePath[i].path
                DlgMgr:sendMsg(dlgName, callback, orgPath, para, objectName)
            end
        end


        -- 需要向阿里云请求，先判断该对话框是否已经有队列在等待，有的话，直接放进队列里
        local isSmallLoading = BlogMgr.autoLoadSmallPicturies[dlgName] and next(BlogMgr.autoLoadSmallPicturies[dlgName]) and true or false  -- isSmallLoading表示，缩略图中有

        if isForce then
            -- 某一次请求结束后，强制执行
            toUrlget(callback, dlgName, objectName, options, para)
        elseif isSmallLoading then
            -- 队列中有排队，放进队列中排队
            BlogMgr:pushInAutoLoad(callback, dlgName, objectName, options, para)
        else
            -- 当前没有队列排队，放进队列里，等请求结果出来后，再将其移除队列
            BlogMgr:pushInAutoLoad(callback, dlgName, objectName, options, para)

            toUrlget(callback, dlgName, objectName, options, para)
        end
    end
end

function BlogMgr:cleanAutoLoad(dlgName)
    BlogMgr.autoLoadSmallPicturies[dlgName] = nil
end

-- 上传文件(异步操作)
function BlogMgr:cmdUpload(opType, dlgName, funcName, ...)
    local files = { ... }

    if not self.uploadReq then
        self.uploadReq = {}
    end

    local cookie = gfGetMd5(table.concat(files))
    self.uploadReq[cookie] = {dlgName = dlgName, funcName = funcName, files = files}

    local suffixs = {}
    for i = 1, #files do
        local fileExt = gf:getFileExt(files[i])
        if 'amr' == fileExt then
            table.insert(suffixs, string.format("_%s.%s", tostring(gfGetFileSize(files[i])), fileExt))
        else
            table.insert(suffixs, string.format(".%s", fileExt))
        end
    end
    gf:CmdToServer('CMD_BLOG_RESOURE_GID', { op_type = opType, suffixs = suffixs, cookie = cookie })
end

-- 文件id申请回调
function BlogMgr:MSG_BLOG_RESOURE_GID(data)
    if not self.uploadReq then return end
    local item = self.uploadReq[data.cookie]
    self.uploadReq[data.cookie] = nil
    if 0 == data.is_ok then
        if item then
            DlgMgr:sendMsg(item.dlgName, item.funcName or "onFinishUpload", item.files, {})
        end
        return
    end
    if not item or not item.files or #(item.files) <= 0 or #(item.files) ~= #(data.gids) then return end
    local dlg = DlgMgr:getDlgByName(item.dlgName)
    if not dlg then return end

    local root = dlg.root
    local o = root:getChildByName('ali-oss')
    if not o then
        o = oss.new({ bucket = BUCKET, authorizationServer = function(o) self:requestAuthorization(item.dlgName, o) end, endpoint = ENDPOINT, upload = UPLOAD_PAGE })
        o:setName('ali-oss')
        root:addChild(o)
    end
    local count = #(item.files)
    local uploads = {}
    local left = count
    for i = 1, count do
        local ext = gf:getFileExt(item.files[i])
        local objectName
        if "amr" == ext then
            objectName = string.format("%s/%s_%s.%s", Me:queryBasic("gid"), data.gids[i], tostring(gfGetFileSize(item.files[i])), gf:getFileExt(item.files[i]))
        else
            objectName = data.gids[i]
        end

        o:post(function(data)
            if data then
                table.insert(uploads, objectName)
                if self:moveFile(item.files[i], ResMgr:getBlogPath(objectName)) then
                    self:accessFile(objectName)
                end
                Log:I("Upload file:%s", objectName)
            end

            left = left - 1
            if left <= 0 then
                -- 已经全部上传完毕
                DlgMgr:sendMsg(item.dlgName, item.funcName or "onFinishUpload", item.files, uploads)
            end
        end, objectName, item.files[i])
    end
end

-- 移动文件
function BlogMgr:moveFile(srcPath, dstPath)
    if not srcPath or not dstPath or not gf:isFileExist(srcPath) then return end

    gfSaveFile("", dstPath)
    dstPath = cc.FileUtils:getInstance():getWritablePath() .. dstPath
    local f = io.open(srcPath, 'rb')
    if f then
        local data = f:read("*a")
        f:close()
        f = io.open(dstPath, "wb")
        if f then
            f:write(data)
            f:close()
            Log:I("move file (%s) -> (%s)", srcPath, dstPath)
            return true
        end
    end
end

function BlogMgr:queryHMacSha1Base64(key, str, callback)
    if not self.queryCookie then
        self.queryCookie = {}
    end

    self.queryCookie[str] = callback
    gf:CmdToServer("CMD_HMAC_SHA1_BASE64", { key = key, contents = { str } })
end

function BlogMgr:MSG_HMAC_SHA1_BASE64(data)
    if not data.rets or not self.queryCookie then return end

    for k, v in pairs(data.rets) do
        local callback = self.queryCookie[k]
        if callback then
            local dlg = DlgMgr:getDlgByName(callback.dlgName)
            if dlg and dlg.root then
                local o = dlg.root:getChildByName("ali-oss")
                if o and tostring(o) == callback.o and 'function' == type(callback.callback) then
                    callback.callback(v)
                end
            end
        end
    end
end

function BlogMgr:requestAuthorization(dlgName, o)
    local doCmdToken = nil
    if not self.requestAuths then
        self.requestAuths = {}
        doCmdToken = true
    end

    if dlgName then
        self.requestAuths[dlgName] = o
	end

    if doCmdToken then
        gf:CmdToServer("CMD_BLOG_OSS_TOKEN")
	end
end

function BlogMgr:MSG_BLOG_OSS_TOKEN(data)
    if not self.requestAuths then
        return
    end


    for k, v in pairs(self.requestAuths) do
        local dlg = DlgMgr:getDlgByName(k)
        if dlg and dlg.root then
            local o = dlg.root:getChildByName("ali-oss")
            if o == v then
                o:refreshAuthorization(data.ret)
            end
         end
    end

    self.requestAuths = nil
end

-- 图片剪裁
-- 将指定剪裁框(clipSize)的图片缩放到指定尺寸(scaleSize)
function BlogMgr:comDoOpenPhoto(state, funcName, clipSize, scaleSize)
    local cw, ch = BlogMgr:getPortraitClipRange()
    gf:comDoOpenPhoto(state, funcName, cc.size(cw, ch), cc.size(256, 256))
end

MessageMgr:regist("MSG_BLOG_RESOURE_GID", BlogMgr)
MessageMgr:regist("MSG_HMAC_SHA1_BASE64", BlogMgr)
MessageMgr:regist("MSG_BLOG_OSS_TOKEN", BlogMgr)

-- 加载必须的模块
require("mgr/blogs/BlogMgrInfos")
require("mgr/blogs/BlogMgrCircle")
require("mgr/blogs/BlogMgrMessages")
require("mgr/blogs/BlogMgrDecorate")

BlogMgr:init()
