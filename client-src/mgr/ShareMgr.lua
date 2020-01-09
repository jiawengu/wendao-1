-- ShareMgr.lua
-- created by liuhb Feb/29/2016
-- 分享管理器

ShareMgr = Singleton()

local PLATFORM_CONFIG = require("PlatformConfig")

local SHARE_SAVE_PATH = "share/"
local shareRoot = nil
local curSharePlat = 0

local CAPTURE_IN_THREAD =  1
local CAPTURE_FAILED    =  2
local CAPTURE_SUCCESS   =  3

local isInCapture = CAPTURE_SUCCESS

local PLAT_NOT_EXSIST_INFO = {
    [SHARE_TYPE.WECHAT] = CHS[3004306],
    [SHARE_TYPE.WECHATMOMENTS] = CHS[3004306],
}

local PLAT_MSG = {
    ["WXNOTSUPPORT"] = CHS[3004438],
    ["UNKNOW"] = CHS[3004439],
}

-- 分享活动图片
local SHARE_ACT_IMAGE = {
    ["movie_hancheng_fenxiang"] = ResMgr.ui.hc_share_pic, -- 《悍城》分享图片
}

-- 有些已有的分享图片需再添加些子图片，如：二维码
local SHARE_SUB_IMAGE = {
    [PLATFORM_CONFIG.SHARE_IMAGE or ResMgr.ui.sys_share_pic] = {
        {icon = ResMgr.ui.sys_share_pic_qr_code, pos = cc.p(1610, 100), limitFunc = "isOffice"}
    }
}

local function init()
    if not shareRoot then
        shareRoot = cc.FileUtils:getInstance():getWritablePath() .. SHARE_SAVE_PATH
        gfCreateWritablePath(shareRoot)
    end

    -- 注册分享功能
    ShareMgr:registerWXApp()
end

-- 跨平台注册app_id
local callRegisterAppIdFun = function(fun, args)
    local v = fun .. ":nil"
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/ShareHelper'
        local sig = '(Ljava/lang/String;)V'
        local para = {}
        para[1] = args["appId"]
        local ok, ret = luaj.callStaticMethod(className, fun, para, sig)
        if ok then
            v = ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok, ret = luaoc.callStaticMethod('ShareHelper', fun, args)
        if ok then
            v = ret
        end
    end

    return v
end

-- 跨平台调用分享图片
local callSharePicFun = function(fun, args)
    local v = fun .. ":nil"
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/ShareHelper'
        local sig = '(ILjava/lang/String;)V'
        local para = {}
        para[1] = args["shareType"]
        para[2] = args["imagePath"]
        local ok, ret = luaj.callStaticMethod(className, fun, para, sig)
        if ok then
            v = ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok, ret = luaoc.callStaticMethod('ShareHelper', fun, args)
        if ok then
            v = ret
        end
    end

    return v
end

-- 跨平台调用分享url
local callShareUrlFun = function(fun, args)
    local v = fun .. ":nil"
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/ShareHelper'
        local sig = '(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V'
        local para = {}
        para[1] = args["shareType"]
        para[2] = args["url"]
        para[3] = args["title"]
        para[4] = args["des"]
        para[5] = args["thumbPath"]
        local ok, ret = luaj.callStaticMethod(className, fun, para, sig)
        if ok then
            v = ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok, ret = luaoc.callStaticMethod('ShareHelper', fun, args)
        if ok then
            v = ret
        end
    end

    return v
end

-- 截图回调
local function captureResult(result, outputFile, toShare)
    -- 取消标记
    ShareMgr:setCapStatus(result)
    if CAPTURE_IN_THREAD == result then
        -- 关闭底下的面板
    elseif CAPTURE_SUCCESS == result then
        DlgMgr:closeDlg("WaitDlg")
        if "function" == type(toShare) then
            toShare()
        end
    elseif CAPTURE_FAILED == result then
        gf:ShowSmallTips(CHS[3004307])
        DlgMgr:closeDlg("WaitDlg")
    end

    DlgMgr:closeDlg("ShareLineDlg")
    DlgMgr:closeDlg("ArenajlDlg")
    DlgMgr:closeDlg("AnniversaryShareDlg")
end

-- 是否正在分享
function ShareMgr:isInCap()
    return isInCapture == CAPTURE_IN_THREAD
end

-- 设置分享状态
function ShareMgr:setCapStatus(status)
    isInCapture = status
end

-- 分享操作
function ShareMgr:share(typeStr, preFun, backFun, typeShowCount)
    if not DistMgr:checkCrossDist() then return end

    if self:isInCap() then
        -- 正在截图
        gf:ShowSmallTips(CHS[3004308])
        return
    end

    -- 拼接文件名称
    typeStr = typeStr or ""
    local fileName = self:createPicFileName(typeStr)

    -- WDSY-24191 中改为先点击“微信”、“朋友圈”按钮后再截图
    local function startCap(toShare, sharePlat)
        -- 打个标记
        self:setCapStatus(CAPTURE_IN_THREAD)

        -- 开始截图
        cc.utils.captureScreenDirect(self, function()
            Log:D(CHS[3004309])
            if "function" == type(preFun) then
                preFun()
            end

            DlgMgr:closeDlg("ShareDlg")

            -- 打开额外的一些水印
            if typeStr == SHARE_FLAG.LEITAI then
                DlgMgr:openDlg("ArenajlDlg", nil, true)
            end

            if sharePlat ~= SHARE_TYPE.ATMBLOG and typeStr ~= SHARE_FLAG.ZHOUNIANQING then
                -- 分享到个人空间、周年庆，不需要加区组等水印信息
                local dlg = DlgMgr:openDlg("ShareLineDlg", nil, true)
                dlg:updateView(typeStr)
            end

            if typeStr == SHARE_FLAG.ZHOUNIANQING then
                DlgMgr:openDlg("AnniversaryShareDlg", nil, true)
            end

            cc.Director:getInstance():getRunningScene():visit()

            DlgMgr:openDlgEx("WaitDlg", { order = Const.ZORDER_WAIT }, nil, true)
        end, function(result, outputFile)
            captureResult(result, outputFile, toShare)

            if "function" == type(backFun) and self:isInCap() then
                -- 这个时候其实数据已经采集完毕，可以恢复了
                backFun()
            end
        end, fileName)
    end

    local dlg = DlgMgr:openDlgEx("ShareDlg", typeShowCount, nil, true)
    dlg:setCapCallBack(startCap)
    dlg:setCurShareData({typeStr = typeStr, fileName = fileName})
end

function ShareMgr:shareUrl(data)
    local dlg = DlgMgr:openDlgEx("ShareDlg", 2)
    dlg:setShareType(SHARE_TYPE_CONFIG.SHARE_URL)
    dlg:setCurShareData(data)
end

-- 分享已知图片
function ShareMgr:sharePic(imagePath)
    if not DistMgr:checkCrossDist() then return end

    if SHARE_SUB_IMAGE
        and SHARE_SUB_IMAGE[imagePath]
        and (not SHARE_SUB_IMAGE[imagePath][1]["limitFunc"] or self[SHARE_SUB_IMAGE[imagePath][1]["limitFunc"]](self)) then
        -- 有多张图需要合并

        -- 创建主图
        local sprite = cc.Sprite:create(imagePath)
        local size = sprite:getContentSize()
        sprite:setAnchorPoint(0, 0)
        sprite:setPosition(0, 0)

        -- 调整视口大小，否则无法在超出视口的位置渲染图片
        local gl = cc.Director:getInstance():getOpenGLView()
        local designResolutionPolicy = gl:getResolutionPolicy()
        local origSize = gl:getDesignResolutionSize()
        gl:setDesignResolutionSize(size.width, size.height, cc.ResolutionPolicy.SHOW_ALL)

        -- 创建画布
        local rt = cc.RenderTexture:create(size.width, size.height)
        rt:retain()
        rt:beginWithClear(0, 0, 0, 0)

        sprite:visit()

        if SHARE_SUB_IMAGE and SHARE_SUB_IMAGE[imagePath] then
            -- 合并子图
            for i = 1, #SHARE_SUB_IMAGE[imagePath] do
                local sprite = cc.Sprite:create(SHARE_SUB_IMAGE[imagePath][i].icon)
                local pos = SHARE_SUB_IMAGE[imagePath][i].pos
                sprite:setAnchorPoint(0, 0)
                sprite:setPosition(pos)
                sprite:visit()
            end
        end

        rt:endToLua()

        local filePath = self:createPicFileName(SHARE_FLAG.DIRECT)
        local fileName = string.gsub(filePath, cc.FileUtils:getInstance():getWritablePath(), "")
        local saveRet = rt:saveToFile(fileName, false)

        -- 恢复视口
        gl:setDesignResolutionSize(origSize.width, origSize.height, designResolutionPolicy)

        if not saveRet then
            gf:ShowSmallTips(CHS[3004307])
            rt:release()
            return
        else
            performWithDelay(gf:getUILayer(), function()
                -- 延时一帧删除确保图片已保存
                rt:release()

                local dlg = DlgMgr:openDlgEx("ShareDlg", 2)
                dlg:setCurShareData({typeStr = SHARE_TYPE.DIRECT, fileName = filePath})
            end, 0)
        end
    else
        local dlg = DlgMgr:openDlgEx("ShareDlg", 2)
        local filePath = cc.FileUtils:getInstance():fullPathForFilename(imagePath)
        dlg:setCurShareData({typeStr = SHARE_TYPE.DIRECT, fileName = filePath})
    end
end

-- 分享到平台
function ShareMgr:shareToPlat(shareType, shareData)
    if self:isInCap() then
        return
    end

    callSharePicFun("shareToPlat", {
        ["shareType"] = shareType,
        ["imagePath"] = shareData.fileName
    })
end

-- 分享Url
-- needNotifyServer 可以是一个函数或者一个 bool 值
-- 如果是函数，则分享结束后会执行 needNotifyServer(result) result 取值如下：
--     WXNOTEXISTS 微信不存在
--     WXNOTSUPPORT 微信不支持分享
--     SHARESUCCESS 分享成功
--     SHAREFAILD 分享失败
function ShareMgr:shareUrlToPlat(shareType, url, title, desc, thumbPath, needNotifyServer, shareFlag)
    local args = {
        ["shareType"] = shareType or SHARE_TYPE.WECHATMOMENTS,
        ["url"] = url or "wd.leiting.com",
        ["title"] = title or "wd",
        ["des"] = desc or "wd",
        ["thumbPath"] = thumbPath or cc.FileUtils:getInstance():fullPathForFilename(ResMgr.ui.atm_logo);
    }

    self.needNotifyServer = needNotifyServer -- 分享成功需要通知服务端
    callShareUrlFun("shareUrlToPlat", args)

    -- 记录分享日志
    ShareMgr:recordShareAction(args.shareType, shareFlag)
end

-- 应用不存在
function ShareMgr:shareAppNotExsist(result)
    if type(self.needNotifyServer) == 'function' then
        self.needNotifyServer('WXNOTEXISTS')
        return
    end

    local str = PLAT_NOT_EXSIST_INFO[tonumber(result)]

    if nil == str then
        str = CHS[3004310]
    end

    gf:ShowSmallTips(str)
end

-- 评论跳转
function ShareMgr:comment()
    if gf:isIos() then
        DeviceMgr:openUrl("https://itunes.apple.com/app/id1031897589?action=write-review")
    elseif gf:isAndroid() then
        if not LeitingSdkMgr:goAndroidComment() then
            gf:ShowSmallTips(CHS[2200154])
        end
    end
end

-- 调用成功
function ShareMgr:shareResult(result)
    if type(self.needNotifyServer) == 'function' then
        self.needNotifyServer(result)
        return
    end

    if result == "SHARESUCCESS" then  -- 分享成功
        if self.needNotifyServer then
            gf:CmdToServer("CMD_SHARE_WITH_FRIENDS", {actName = self.shareActName and self.shareActName or ""})
            self.needNotifyServer = false
        end
    elseif result == "SHAREFAILD" then -- 分享失败

    else
        local msg = PLAT_MSG[result]
        if not msg then
            msg = PLAT_MSG["UNKNOW"]
        end

        gf:ShowSmallTips(msg)
    end
end

-- java全局调用
function ShareMgrGlobalCall(result)
    local mgr, func, paras = string.match(result, "(.+):(.+)%((.*)%)")
    if "table" == type(_G[mgr]) and "function" == type(_G[mgr][func]) then
        _G[mgr][func](_G[mgr], paras)
    else
        Log:D("cannot find Mgr method : " .. result)
    end
end

-- 获取文件名称
function ShareMgr:createPicFileName(typeStr)
    typeStr = typeStr or ""
    return shareRoot .. typeStr .. os.date("%Y%m%d%H%M%S", os.time()) .. ".jpg"
end

function ShareMgr:getWXAppId()
    local appId
    if gf:isAndroid() and gf:gfIsFuncEnabled(FUNCTION_ID.ANDROID_META_DATA) then
        appId = AndroidUtil:callStatic("org/cocos2dx/lua/AppActivity", "getAppMetaData", "(Ljava/lang/String;)Ljava/lang/String;", { "WX_APP_ID" })
    end

    if string.isNilOrEmpty(appId) and PLATFORM_CONFIG.WX_APP_ID and "string" == type(PLATFORM_CONFIG.WX_APP_ID) then
        appId = PLATFORM_CONFIG.WX_APP_ID
    end

    return appId
end

-- 获取配置微信的app_id
function ShareMgr:registerWXApp()
    if "table" == type(GFiltrateMgr)
        and "function" == type(GFiltrateMgr.Instance) then
        -- 暂时使用这个函数判断，如果存在这个函数则说明可以使用非官方的分享功能 WDSY-10083
        Log:I(">>>> ShareMgr can use not official.")
        local appId = self:getWXAppId()
        if not string.isNilOrEmpty(appId) then
            callRegisterAppIdFun("registerWXApp", { appId = appId })
        end
    end
end

-- 是否显示分享按钮
function ShareMgr:isShowShareBtn()
    if "table" == type(GFiltrateMgr)
        and "function" == type(GFiltrateMgr.Instance) then
        -- 暂时使用这个函数判断，如果存在这个函数则说明可以使用非官方的分享功能 WDSY-10083
        Log:I(">>>> ShareMgr can use not official.")
        return "true" == PLATFORM_CONFIG.IS_SHARE or true == PLATFORM_CONFIG.IS_SHARE
    else
        if (gf:isAndroid() and DistMgr:isOfficalDist())
            or (gf:isIos() and LeitingSdkMgr:isLeiting())
            or gf:isWindows() then
            return true
        else
            return false
        end
    end
end

-- 获取系统界面分享的图片
function ShareMgr:getSysShareImage()
    return PLATFORM_CONFIG.SHARE_IMAGE or ResMgr.ui.sys_share_pic
end

-- 是否是官方渠道
function ShareMgr:isOffice()
    if nil == PLATFORM_CONFIG.IS_OFFICIAL then
        return false
    end

    return "true" == PLATFORM_CONFIG.IS_OFFICIAL or true == PLATFORM_CONFIG.IS_OFFICIAL
end

-- 活动分享
-- 暂时处理分享图片的逻辑，后续有其他分享类型再扩展
function ShareMgr:MSG_OPEN_SHARE_FRIEND_DLG(data)
    self.shareActName = data.act_name
    if not SHARE_ACT_IMAGE[data.act_name] then return end
    self.needNotifyServer = true
    ShareMgr:sharePic(SHARE_ACT_IMAGE[data.act_name])
end

function ShareMgr:recordShareAction(shareType, shareFlag)
    if shareFlag and SHARE_FLAG[shareFlag] then
        gf:CmdToServer("CMD_LOG_CLIENT_ACTION", {[1] = {action = "fenx", para1 = shareType, para2 = SHARE_FLAG[shareFlag], para3 = "", memo = ""}, count = 1})
    end
end

function ShareMgr:clearData()
    self.shareActName = nil
end

-- 初始化
init()

function ShareMgr:MSG_OPEN_COMMENT_DLG()
    ShareMgr:comment()
end

MessageMgr:regist("MSG_OPEN_COMMENT_DLG", ShareMgr)
MessageMgr:regist("MSG_OPEN_SHARE_FRIEND_DLG", ShareMgr)
