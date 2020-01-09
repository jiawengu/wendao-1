-- CommunityDlg.lua
-- Created by lixh Oct/25/2017
-- 社区界面

local CommunityDlg = Singleton("CommunityDlg", Dialog)

local WaitPanel = require("ctrl/WaitPanel")

-- 记录url的时间为150秒
local RECORD_URL_TIME = 150

-- 页面加载倒计时最大时间
local LOAD_MAX_TIME = 10

-- 默认url
local DEFAULT_URL = "http://vwd.leiting.com/#/index"
local DEFAULT_RAW_URL = DEFAULT_URL

-- 网页标记
local WEBPAGE_TAG = 999

-- 方案处理方法配置
local schemeMethods = {
    ["showArticle"] = "onShowArticle",
    ["shareUrlToWX"] = "onShareUrlToWX",
    ["saveImage"] = "onSaveImage",
    ["shareToSpace"] = "onShareToSpace",
    ["shareToFriend"] = "onShareToFriend",
    ["getFriendList"] = "onGetFriendList",
    ["redirect"] = "onRedirect",
}

local WAIT_PANEL_STR = {
    CHS[7150142],
    CHS[7150142] .. ".",
    CHS[7150142] .. "..",
    CHS[7150142] .. "...",
}

function CommunityDlg:init(data)
    self:bindListener("RefreshButton", self.onRefreshButton, "NoticePanel")

    self.blank:setLocalZOrder(Const.LOADING_DLG_ZORDER - 2)
    local mgrUrl = CommunityMgr:getCommunityURL()
    if mgrUrl then
        DEFAULT_URL = mgrUrl
        DEFAULT_RAW_URL = mgrUrl
    end

    DEFAULT_URL = DEFAULT_RAW_URL

    self:createWaitPanel()

    if gf:isWindows() and ATM_IS_DEBUG_VER then
        return
    end

    -- 先保存一下音乐、音效等开关，以便后续使用
    self.isMusicOnBeforeOpen = SoundMgr:isMusicOn()
    self.isSoundOnBeforeOpen = SoundMgr:isSoundOn()
    self.isDubbingOnBeforeOpen = SoundMgr:isDubbingOn()

    self:setCtrlVisible("NoticePanel", false)

    self:hookMsg("MSG_ENTER_ROOM")

    local lastUrl = CommunityMgr.lastAccessUrl
    local lastCloseDlgTime = CommunityMgr.lastAccessUrlTime
    if lastUrl and lastCloseDlgTime and gf:getServerTime() - tonumber(lastCloseDlgTime) <= RECORD_URL_TIME then
        self.curUrl = lastUrl
    else
        self.curUrl = DEFAULT_URL
    end

    if data and #data > 0 then
        -- 带参数打开微社区(包括token及红点信息)
        self.curUrl = self.curUrl .. self:getAddSuffixSymbol(self.curUrl) .. CommunityMgr:makeQueryString(data)
    end

    -- 平台要求url带上官府和渠道服后缀
    if not string.match(self.curUrl, CommunityMgr:getQuDaoSuffix()) then
        self.curUrl = self.curUrl .. self:getAddSuffixSymbol(self.curUrl) .. CommunityMgr:getQuDaoSuffix()
    end

    -- 清空社区链接访问后缀，后缀只生效一次
    CommunityMgr:clearCommunityUrlSuffix()

    self:createWebView()

    self.webView:loadURL(self.curUrl)
    local startTime = LOAD_MAX_TIME
    self.waitPanel:setVisible(true)
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            if startTime > 0 then
                -- 显示倒计时
                startTime = startTime - 1
            else
                if self.curUrl ~= DEFAULT_URL then
                    -- 加载主页并重新倒计时
                    self.curUrl = DEFAULT_URL
                    self.webView:loadURL(self.curUrl)
                    startTime = LOAD_MAX_TIME
                else
                    -- 加载失败
                    self:clearSchedule()
                    self:removeWebView()

                    self.waitPanel:setVisible(false)
                    self:setCtrlVisible("NoticePanel", true)
                end
            end
        end, 1)
    end

    -- 尝试显示微社区，如果此时有确认框打开，会隐藏微社区
    self:setVisible(true)

    -- WDSY-32596 微社区打开白屏时间过长的问题：需要默认隐藏webview
    self.webView:setVisible(false)

    self.inPreLoad = nil

    self:MSG_ENTER_ROOM()
end

function CommunityDlg:createWaitPanel()
    self.waitPanel = self:getControl("WaitPanel")
    self.waitPanelScheduleId = self:startSchedule(function()
        self:refreshWaitPanel()
    end, 0.3)
end

function CommunityDlg:refreshWaitPanel()
    local curStr = self:getLabelText("InfoLabel2", self.waitPanel)
    if curStr == WAIT_PANEL_STR[1] then
        self:setLabelText("InfoLabel2", WAIT_PANEL_STR[2], self.waitPanel)
    elseif curStr == WAIT_PANEL_STR[2] then
        self:setLabelText("InfoLabel2", WAIT_PANEL_STR[3], self.waitPanel)
    elseif curStr == WAIT_PANEL_STR[3] then
        self:setLabelText("InfoLabel2", WAIT_PANEL_STR[4], self.waitPanel)
    else
        self:setLabelText("InfoLabel2", WAIT_PANEL_STR[1], self.waitPanel)
    end
end

-- 获取增加后缀时的连接符
-- 在 url 中都有 "?" 时返回 "?" ，其他情况返回 "&"
function CommunityDlg:getAddSuffixSymbol(url)
    if not string.isNilOrEmpty(url) and not string.find(url, "?") then
        return "?"
    end

    return "&"
end

-- 移除当前url中的指定串
function CommunityDlg:removeUrlSuffix(str)
    if self.curUrl then
        local left, right = string.find(self.curUrl, str)
        if left and right then
            self.curUrl = string.sub(self.curUrl, 1, left - 1) .. string.sub(self.curUrl, right + 1, -1)
        end
    end
end

-- 刷新当前url
function CommunityDlg:refreshCurUrl()
    if not self.curUrl then return end

    self:createWebView()

    self.webView:loadURL(self.curUrl)
    local startTime = LOAD_MAX_TIME
    self.waitPanel:setVisible(true)
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            if startTime > 0 then
                -- 显示倒计时
                startTime = startTime - 1
            else
                -- 加载失败
                self:clearSchedule()
                self:removeWebView()
                self.waitPanel:setVisible(false)
                self:setCtrlVisible("NoticePanel", true)
            end
        end, 1)
    end
end

function CommunityDlg:tryToResumeMusic()
    if self.isPlayVideo then
        -- 网页有视频，如果打开该界面前有播放音乐，需要还原
        if self.isMusicOnBeforeOpen then
            SoundMgr:resumeMusic()
        end

        if self.isSoundOnBeforeOpen then
            SoundMgr:resumeSound()
        end

        if self.isDubbingOnBeforeOpen then
            SoundMgr:resumeDubbing()
        end

        self.isPlayVideo = false
    end
end

function CommunityDlg:onShowArticle(args)
    local type = args.type
    if type == 'video' then
        -- 网页中有视频，如果还在播放音乐，则需要暂停
        self.isPlayVideo = true
        if self.isMusicOnBeforeOpen then
            SoundMgr:pauseMusic()
        end

        if self.isSoundOnBeforeOpen then
            SoundMgr:pauseSound()
        end

        if self.isDubbingOnBeforeOpen then
            SoundMgr:stopDubbing()
        end
    else
        -- 网页从有视频切换到无视频，如果播放视频前有播放背景音乐，需要还原
        self:tryToResumeMusic()
    end
end

-- 分享地址到微信
function CommunityDlg:onShareUrlToWX(args)
    -- 处理分享
    local type = SHARE_TYPE.WECHAT
    if args.type == 'circle' then
        -- 朋友圈
        type = SHARE_TYPE.WECHATMOMENTS
    end

    ShareMgr:shareUrlToPlat(type, args.url, args.title, args.desc, self:getThumbPath(), function(result)
        if not self.webView then
            return
        end

        local r = tostring(result)
        local jsCode = "if (typeof(atmShareCallback) == 'function'){ atmShareCallback('" .. r .. "', ''); }else{ alert('" .. r .. "');}"
        self.webView:evaluateJS(jsCode)
        -- Log:I("evaluateJS(%s)", jsCode)
    end)
end

-- 保存图片
function CommunityDlg:onSaveImage(args)
    local url = args.url
    if not gf:gfIsFuncEnabled(FUNCTION_ID.SAVE_TO_GALLERY) then
        local jsCode = string.format("atmDownloadFinish(\"%s\", \"%s\", \"%s\");", "unsupport", url, "")
        self.webView:evaluateJS(jsCode)
        return
    end

    local httpFile = HttpFile:create()
    self:regHttpReq(httpFile)

    local filePath = string.format("saves/atm%d%d.jpg", os.time(), gfGetTickCount())
    gfSaveFile("", filePath)
    filePath = cc.FileUtils:getInstance():getWritablePath() .. filePath

    -- 回调请求
    local function _callback(state, value)
        if not self.reqs then return end    -- 已经析构没有数据了，直接返回，不需要处理

        if 1 == state then
            local jsCode = string.format("atmDownloadProgress(\"%s\", %d);", url, value)
            self.webView:evaluateJS(jsCode)
        elseif 0 == state then
            -- 已经完成作业，释放对象
            -- 保存到相册
            if gf:isAndroid() then
                local luaj = require('luaj')
                local className = 'org/cocos2dx/lua/AppActivity'
                local sig = "(Ljava/lang/String;I)Ljava/lang/String;"
                local args = { filePath, 80 }
                local fun = "saveImageToGallery"
                local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
                if ok then
                    filePath = ret
                end
            elseif gf:isIos() then
                local luaoc = require('luaoc')
                local args = {["arg1"] = filePath}
                local ok, ret = luaoc.callStaticMethod('AppController', "saveImageToGallery", args)
                if ok then
                    filePath = ret
                end
            end

            local jsCode = string.format("atmDownloadFinish(\"%s\", \"%s\", \"%s\");", "success", url, filePath)
            self.webView:evaluateJS(jsCode)
            self:unregHttpReq(httpFile)
        elseif 2 == state then
            local jsCode = string.format("atmDownloadFinish(\"%s\", \"%s\", \"%s\");", "fail", url, "")
            self.webView:evaluateJS(jsCode)
            os.remove(filePath)

            -- 已经完成作业，释放对象
            self:unregHttpReq(httpFile)
        end
    end

    httpFile:setDelegate(_callback)
    httpFile:downloadFile(url, filePath)
end

-- 分享到个人空间
function CommunityDlg:onShareToSpace(args)
    if Me:getLevel() < 40 then
        local sendTip = CHS[2200092]
        local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHAREFAILED', sendTip, sendTip)
        self.webView:evaluateJS(jsCode)
        return
    end

    local title = args.title
    local articleId = args.articleId
    local comment = args.comment

    local filtTextStr = gfFiltrate(comment or "", false)
    if not string.isNilOrEmpty(filtTextStr) then
        sendTip = CHS[2200093]
        local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHAREFAILED', sendTip, sendTip)
        self.webView:evaluateJS(jsCode)
        return
    end

    local content = string.format("{\t%s\27%s\27%s\t}", title, articleId, comment)
    local viewType = 0
    BlogMgr:publishStatus(content, "", viewType)

    local sendTip = CHS[2200082]
    local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHARESUCCESS', sendTip, sendTip)
    self.webView:evaluateJS(jsCode)
end

-- 分享到好友
function CommunityDlg:onShareToFriend(args)
    local title = args.title
    local articleId = args.articleId
    local comment = args.comment
    local gid = args.id

    local friend = FriendMgr:getFriendByGid(gid)
    local content = string.format("{\t%s\27%s\27%s\t}", title, articleId, "")
    local sendTip
    if friend then
        local filtTextStr = gfFiltrate(comment or "", false)
        if not string.isNilOrEmpty(filtTextStr) then
            sendTip = CHS[2200093]
            local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHAREFAILED', sendTip, sendTip)
            self.webView:evaluateJS(jsCode)
            return
        end

        FriendMgr:sendMsgToFriend(friend:queryBasic("char"), content, gid)

        if not string.isNilOrEmpty(comment) then
            FriendMgr:sendMsgToFriend(friend:queryBasic("char"), comment, gid)
        end
        sendTip = string.format(CHS[2200083], friend:queryBasic("char"))
    else
        local group = FriendMgr:getChatGroupInfoById(gid)
        if not group then return end

        local filtTextStr = gfFiltrate(comment or "", false)
        if not string.isNilOrEmpty(filtTextStr) then
            sendTip = CHS[2200093]
            local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHAREFAILED', sendTip, sendTip)
            self.webView:evaluateJS(jsCode)
            return
        end

        FriendMgr:sendMsgToChatGroup(group:queryBasic("group_name"), content, gid)

        if not string.isNilOrEmpty(comment) then
            FriendMgr:sendMsgToChatGroup(group:queryBasic("group_name"), comment, gid)
        end
        sendTip = string.format(CHS[2200084], group:queryBasic("group_name"))
    end

    if sendTip then
        local jsCode = string.format("if (typeof(atmShareCallback) == 'function'){ atmShareCallback('%s', '%s'); }else{ alert('%s');}", 'SHARESUCCESS', sendTip, sendTip)
        self.webView:evaluateJS(jsCode)
    end
end

-- 获取好友列表
function CommunityDlg:onGetFriendList(args)
    local list = {}
    local friends = {}
    local recents = {}
    local groups = {}

    -- 获取好友列表
    local friendList = FriendMgr:getObjsByGroup()
    if friendList then
        for k, v in pairs(friendList) do
            local f = {}
            f.icon = v:queryInt("icon")
            f.level = v:queryInt("level")
            f.name = v:queryBasic("char")
            f.party = v:queryBasic("party/name")
            f.id = v:queryBasic("gid")
            f.is_online = v:queryInt("online")
            table.insert(friends, f)
        end
    end

    -- 获取最近联系列表
    local recentList = FriendMgr:getRecentFriends()
    if recentList then
        for k, _ in pairs(recentList) do
            local f = {}
            local v = FriendMgr:getFriendByGid(k)
            if v then
                f.icon = v:queryInt("icon")
                f.level = v:queryInt("level")
                f.name = v:queryBasic("char")
                f.party = v:queryBasic("party/name")
                f.id = v:queryBasic("gid")
                f.is_online = v:queryInt("online")
                table.insert(recents, f)
            end
        end
    end

    -- 区组信息
    local groupList = FriendMgr:getChatGroupsData()
      for i = 1, #groupList do
        local g = {}
        local v = groupList[i]
        local list =  FriendMgr:getGroupByGroupId(v.group_id)
        local online, total = FriendMgr:getOnlinAndTotaleCounts(list)
        g.online_num = online
        g.total = total
        g.name = v.group_name
        g.id = v.group_id
        local info = FriendMgr:getChatGroupInfoById(v.group_id)
        if info then
            g.icon = info:queryInt("icon")
        end
        table.insert(groups, g)
    end

    list.friends = friends
    list.recent = recents
    list.groups = groups

    local str = require("json").encode(list)
    local jsCode = string.format("var o = JSON.parse(\"%s\"); atmFriendList(o);", str.gsub(str, "\"", "\\\""))
    self.webView:evaluateJS(jsCode)
end

-- 页面跳转
function CommunityDlg:onRedirect(args)
    if not args then return end
    local url  = args.url

    local index = string.find(DEFAULT_RAW_URL, "/index")
    local baseUrl = string.sub(DEFAULT_RAW_URL, 1, index - 1)
    url = baseUrl .. url
    self.curUrl = url
end

function CommunityDlg:regHttpReq(req)
    if not self.reqs then self.reqs = {} end

    self.reqs[tostring(req)] = req
    req:retain()
end

function CommunityDlg:unregHttpReq(req)
    if not self.reqs then return end
    if req then
        self.reqs[tostring(req)] = nil
        req:release()
    else
        for _, v in pairs(self.reqs) do
            if v then
                v:release()
            end
        end

        self.reqs = nil
    end
end

-- 获取小图标路径
function CommunityDlg:getThumbPath()
    return cc.FileUtils:getInstance():fullPathForFilename(ResMgr.ui.atm_share_url_logo)
end

-- 解析 Web 层传给回调的 url
-- 例如：atm://shareUrlToWX?title=xx&desc=xx&url=xx&type=friend
-- 返回：一张表，包含 scheme、method 和 args
function CommunityDlg:parseAtmScheme(schemeUrl)
    local url = require("url")
    local info = {}
    info.scheme, info.host = string.match(schemeUrl, "([^:]+)://(.*)")
    local pos = gf:findStrByByte(info.host, '?')
    if not pos then
        info.method = info.host
        return info
    end

    info.method = string.sub(info.host, 1, pos - 1)
    info.args = {}
    local list = gf:split(string.sub(info.host, pos + 1) or "", '&')
    for i = 1, #list do
        local kv = list[i]
        pos = gf:findStrByByte(kv, '=')
        if pos and pos > 1 then
            info.args[string.sub(kv, 1, pos - 1)] = url.unescape(string.sub(kv, pos + 1))
        end
    end

    return info
end

-- 隐藏或显示界面
function CommunityDlg:setVisible(flag, ignoreLoading, ignorePreLoad)
    if self.setVisibleAction then
        self.root:stopAction(self.setVisibleAction)
        self.setVisibleAction = nil
    end

    if flag and not DlgMgr:canShowWebDlg(ignoreLoading, self.name) then
        flag = false
    end

    if flag then
        if not ignorePreLoad and self.inPreLoad then
            -- 正在预加载，不处理
            return
        end

        Dialog.setVisible(self, flag)
    else
        -- 隐藏时需要延迟一帧，避免self.webView:setPositionX(10000)不生效
        self.setVisibleAction = performWithDelay(self.root, function()
            Dialog.setVisible(self, flag)
        end, 0)
    end

    if self.webView then
        local noticePanel = self:getControl("NoticePanel")
        if flag and not noticePanel:isVisible() then
            -- WDSY-35188 webView调用setVisible会导致正在输入的输入法异常，所以调整为setPositionX
            self.webView:setPositionX(0)
        else
            self.webView:setPositionX(10000)
        end
    end
end

-- 刷新网页
function CommunityDlg:onRefreshButton(sender, eventType)
    self:refreshCurUrl()
end

-- 创建webView
function CommunityDlg:createWebView()
    if self.webView then return end
    self.webView = ccexp.WebView:create()
    local webPanel = self:getControl("WebPanel")
    local panelSize = webPanel:getContentSize()
    self.webView = ccexp.WebView:create()
    if gf:isIos() and DeviceMgr:getOSVer() >= "8" and 'function' == type(self.webView.useWKWebViewInIos) then
        self.webView:useWKWebViewInIos(true) -- 切记，一定要在创建之后马上设置，否则调用了其他接口之后WebView控件可能就被创建出来了
    end
    self.webView:setScalesPageToFit(true)
    self.webView:setContentSize(panelSize)
    self.webView:setAnchorPoint(0, 0)
    self.webView:setTag(WEBPAGE_TAG)
    webPanel:addChild(self.webView)
    self.webView:setVisible(false)

    self.webView:setOnDidFailLoading(function(sender, url)
        if CommunityMgr:getPreLoadCommunityType() == PRELOAD_COMMUNITY_TYPE.RED_POINT
            and CommunityMgr:getPreLoadRedDotData() then
            RedDotMgr:updateMailRedDot(CommunityMgr:getPreLoadRedDotData())
        end

        CommunityMgr:setPreLoadCommunityType(PRELOAD_COMMUNITY_TYPE.NONE)

        self.loadOver = true

        if not DlgMgr:isDlgOpened(self.name) then
            return
        end

        if url ~= DEFAULT_URL then
            return
        end

        self:clearSchedule()
        self.waitPanel:setVisible(false)

        self:setCtrlVisible("NoticePanel", true)
        self:removeWebView()
    end)

    self.webView:setOnDidFinishLoading(function(sender, url)
        if CommunityMgr:getPreLoadCommunityType() == PRELOAD_COMMUNITY_TYPE.RED_POINT
            and CommunityMgr:getPreLoadRedDotData() then
            RedDotMgr:updateMailRedDot(CommunityMgr:getPreLoadRedDotData())
        end

        CommunityMgr:setPreLoadCommunityType(PRELOAD_COMMUNITY_TYPE.NONE)

        self.loadOver = true

        if not DlgMgr:isDlgOpened(self.name) then
            return
        end

        self:clearSchedule()
        self.waitPanel:setVisible(false)
        self:setCtrlVisible("NoticePanel", false)

        if self.webView then
            self.webView:setVisible(self:isVisible())
        end

        self.curUrl = url
    end)

    if 'function' == type(self.webView.setOnJSCallback) then
        self.webView:setOnJSCallback(function(sender, url)
            -- atm://shareUrlToWX?title=xx&desc=xx&url=xx&type=friend
            -- Log:I("OnJSCallback:%s", tostring(url))
            local info = self:parseAtmScheme(url)
                if info.scheme ~= "atm" then
                    -- 格式不对
                    return
                end

        local methodName = info.method
        if string.isNilOrEmpty(methodName) then return end  -- 没有指定的方法
            local method = schemeMethods[methodName]
            if not method or 'function' ~= type(self[method]) then return end
            self[method](self, info.args)
        end)

        self.webView:setJavascriptInterfaceScheme("atm")
    end
end

-- 移除webView
function CommunityDlg:removeWebView()
    if self.webView then
        self.webView:removeFromParent()
        self.webView = nil
    end
end

-- 停止倒计时
function CommunityDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end

    if self.waitPanelScheduleId then
        self:stopSchedule(self.waitPanelScheduleId)
        self.waitPanelScheduleId = nil 
    end
end

function CommunityDlg:cleanup()
    self:clearSchedule()
    self:removeWebView()
    self:tryToResumeMusic()
    self:unregHttpReq()
    self.setVisibleAction = nil
    self.inPreLoad = nil
    self.loadOver = nil
end

function CommunityDlg:onCloseButton()
    CommunityMgr:setLastAcesss(self.curUrl, gf:getServerTime())
    DlgMgr:closeDlg(self.name)
end

function CommunityDlg:MSG_ENTER_ROOM()
    local loadingDlg = DlgMgr:getDlgByName("LoadingDlg")
    if loadingDlg and loadingDlg:isVisible() then
        self:setVisible(false)

        local dlg = DlgMgr:getDlgByName("LoadingDlg")
        dlg:registerExitCallBack(function()
            -- 第2个参数为true的原因是loading结束的回调执行时，loading界面为即将关闭状态，DlgMgr.dlgs中还有loading界面
            -- 且loading界面是确认框类型，但是又需要显示微社区界面，所以增加第2个参数，在setVisible中忽略loading界面检查
            self:setVisible(true, true)
        end)

        return
    end
end

return CommunityDlg
