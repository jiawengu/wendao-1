-- CommunityMgr.lua
-- created by lixh Nov/20/2017
-- 微社区管理器

CommunityMgr = Singleton()

local Bitset = require('core/Bitset')

-- 微社区token信息
local token = nil

-- 微社区url
local url = nil

-- url后缀
local urlSuffix = {}

-- 微社区新手指引url后缀
local COMMUNITY_URL_GUIDE_SUFFIX = "redirect_url=/noviceWay"

-- 微社区红点url后缀
local COMMUNITY_URL_REDPOINT_SUFFIX = "redpoint=yes"

-- 微社区渠道后缀
local COMMUNITY_URL_QD_SUFFIX = {GF = "server=gf", QDF = "server=qdf"}

-- 是否需要打开微社区界面标记
local needOpenDlg = false

-- 存储上一次访问的 url 及访问时间
CommunityMgr.lastAccessUrl = nil
CommunityMgr.lastAccessUrlTime = nil

-- 保存url需要过滤的参数
local URL_FILT_PARA_CFG = {
    ["daoxin_gift_redpoint=yes"] = true,
    ["daoxin_progress_redpoint=yes"] = true,
    [COMMUNITY_URL_REDPOINT_SUFFIX] = true,
}

-- 设置预加载微社区标记
function CommunityMgr:setPreLoadCommunityType(type)
    self.preLoadCommunity = type
end

-- 预加载微社区类型
function CommunityMgr:getPreLoadCommunityType()
    return self.preLoadCommunity
end

-- 设置预加载微社区红点数据
function CommunityMgr:setPreLoadRedDotData(data)
    self.preLoadRedDotData = data
end

-- 获取预加载微社区红点数据
function CommunityMgr:getPreLoadRedDotData()
    return self.preLoadRedDotData
end

-- 请求打开社区界面
function CommunityMgr:askForOpenCommunityDlg()
    local dlg = DlgMgr:getDlgByName("CommunityDlg")
    if dlg then
        -- 如果界面已经打开，不管是否正在预加载，直接显示界面
        dlg:setVisible(true, nil, true)
        dlg.inPreLoad = nil

        -- webView需要在加载完成的时候显示，避免白屏
        if dlg.loadOver then
            dlg.webView:setVisible(true)
        end

        return
    end

    self.toBeOpenUrl = nil
    if token then
        local t = gf:deepCopy(self:getCommunityUrlSuffix())
        self:addUrlPara(t, "token=", self:getToken())
        self:openCommunityDlgByPara(t)
        needOpenDlg = false
    else
        gf:CmdToServer("CMD_REQUEST_COMMUNITY_TOKEN", {})
        needOpenDlg = true
    end
end

-- 请求打开社区界面指定
function CommunityMgr:openCommunityDlg(articleId)
    -- 打开指定文章时，先重置上一次打开链接缓存
    self.lastAccessUrl = CommunityMgr:getCommunityURL()

    self.toBeOpenUrl = nil
    if token then
        local t = gf:deepCopy(self:getCommunityUrlSuffix())
        self:addUrlPara(t, "token=", self:getToken())
        self:addUrlPara(t, "articleId=", articleId)
        self:openCommunityDlgByPara(t)
        needOpenDlg = false
    else
        self.toBeOpenUrl = {type = "articleId", para = articleId}
        gf:CmdToServer("CMD_REQUEST_COMMUNITY_TOKEN", {})
        needOpenDlg = true
    end
end

-- 通过微社区打开指定网页
function CommunityMgr:openCommunityDlgByUrl(destUrl)
    -- 打开指定网页时，先重置上一次打开链接缓存
    self.lastAccessUrl = CommunityMgr:getCommunityURL()

	self.toBeOpenUrl = nil
	if token then
    	local url = require("url")
	    destUrl = url.escape(destUrl)
		local t = gf:deepCopy(self:getCommunityUrlSuffix())
		self:addUrlPara(t, "token=", self:getToken())
		self:addUrlPara(t, "bbsvurl=", destUrl)
        self:openCommunityDlgByPara(t)
		needOpenDlg = false
	else
        self.toBeOpenUrl = {type = "bbsvurl", para = destUrl}
        gf:CmdToServer("CMD_REQUEST_COMMUNITY_TOKEN", {})
        needOpenDlg = true
	end
end

-- 打开微社区界面
function CommunityMgr:openCommunityDlgByPara(t)
    local dlg = DlgMgr:openDlgEx("CommunityDlg", t)
    local preLoadType = self:getPreLoadCommunityType()
    if preLoadType == PRELOAD_COMMUNITY_TYPE.RED_POINT or preLoadType == PRELOAD_COMMUNITY_TYPE.GUIDE then
        dlg.inPreLoad = true
        Dialog.setVisible(dlg, false)
    end
end

-- 点击社区按钮的通用处理
function CommunityMgr:onCommunityButton(sender, eventType, data, isRedDotRemoved)
    if gf:isWindows() then
        return
    end

    if not DistMgr:checkCrossDist() then return end

    if isRedDotRemoved then
        -- 通知服务器取消社区按钮小红点
        gf:CmdToServer("CMD_CANCEL_COMMUNITY_REDPOINT", {})
    end

    -- 尝试移除环绕光效
    if sender:getChildByTag(Const.ARMATURE_MAGIC_TAG) then
        sender:removeChildByTag(Const.ARMATURE_MAGIC_TAG)
    end

    local userDefault = cc.UserDefault:getInstance()
    local meGid = Me:queryBasic("gid")

    -- 内测区组需要检测版本号
    if DistMgr:curIsTestDist() then
        local ver1, ver2 = gf:getVersionValue(require("PlatformConfig").CUR_VERSION)
        if ver1 < "2.017" or (ver1 == "2.017" and ver2 == "1227") then
            local lastClickTime = userDefault:getStringForKey("CommunityClickTime" .. meGid, "0")
            userDefault:setStringForKey("CommunityClickTime" .. meGid, tostring(gf:getServerTime()))

            -- 当天首次点击
            if not gf:isSameDay(tonumber(lastClickTime), gf:getServerTime()) then
                -- 提示框弹出小于5次
                local clickTimes = userDefault:getIntegerForKey("CommunityUpdateTipTime" .. meGid, 0)
                if clickTimes < 5 then
                    userDefault:setIntegerForKey("CommunityUpdateTipTime" .. meGid, clickTimes + 1)

                    -- 继续游戏    前往下载
                    gf:confirmEx(CHS[7150041], CHS[7150039], function()
                        gf:openFullPackageLoadUrl()
                    end, CHS[7150042], function()
                        CommunityMgr:askForOpenCommunityDlg()
                    end)

                    return
                end
            end
        end
    end

    if gf:isIos() then
        if (DeviceMgr:getOSVer() >= "8" and 'function' ~= type(ccexp.WebView.useWKWebViewInIos)) then
            local lastClickTime = userDefault:getStringForKey("CommunityIOSDMClickTime1" .. meGid, "0")
            userDefault:setStringForKey("CommunityIOSDMClickTime1" .. meGid, tostring(gf:getServerTime()))

            -- 当天首次点击
            if not gf:isSameDay(tonumber(lastClickTime), gf:getServerTime()) then
                -- 提示框弹出小于5次
                local clickTimes = userDefault:getIntegerForKey("CommunityIOSDMUpdateTipTime1" .. meGid, 0)
                if clickTimes < 5 then
                    userDefault:setIntegerForKey("CommunityIOSDMUpdateTipTime1" .. meGid, clickTimes + 1)

                    -- 继续游戏    前往下载
                    gf:confirmEx(CHS[2300027], CHS[7150039], function()
                        gf:openFullPackageLoadUrl()
                    end, CHS[7150042], function()
                        CommunityMgr:askForOpenCommunityDlg()
                    end)

                    return
                end
            end
        elseif DeviceMgr:getOSVer() < "8" then
            local lastClickTime = userDefault:getStringForKey("CommunityIOSDMClickTime2" .. meGid, "0")
            userDefault:setStringForKey("CommunityIOSDMClickTime2" .. meGid, tostring(gf:getServerTime()))

            -- 当天首次点击
            if not gf:isSameDay(tonumber(lastClickTime), gf:getServerTime()) then
                -- 提示框弹出小于5次
                local clickTimes = userDefault:getIntegerForKey("CommunityIOSDMUpdateTipTime2" .. meGid, 0)
                if clickTimes < 5 then
                    userDefault:setIntegerForKey("CommunityIOSDMUpdateTipTime2" .. meGid, clickTimes + 1)
                    gf:confirm(CHS[2300026], function()
                        CommunityMgr:askForOpenCommunityDlg()
                    end, nil, nil, nil, nil, nil, true)

                    return
                end
            end
        end
    end

    CommunityMgr:askForOpenCommunityDlg()
end

-- 获取社区token
function CommunityMgr:getToken()
    return token
end

-- 设置社区token
function CommunityMgr:setToken(str)
    token = str
end

-- 获取社区url
function CommunityMgr:getCommunityURL()
    return url
end

-- 设置社区url
function CommunityMgr:setCommunityURL(str)
    url = str
end

-- 获取参数数据
function CommunityMgr:getCommunityUrlSuffix()
    return urlSuffix
end

-- 是否有对应参数
function CommunityMgr:hasCommunityUrlSuffix(str)
    for i = 1, #urlSuffix do
        if urlSuffix[i] == str then return true, i end
    end

    return false
end

-- 增加参数
function CommunityMgr:addCommunityUrlSuffix(str)
    if not self:hasCommunityUrlSuffix(str) then
        table.insert(urlSuffix, str)
    end
end

-- 移除参数
function CommunityMgr:removeCommunityUrlSuffix(str)
    local has, index = self:hasCommunityUrlSuffix(str)
    if has and index then
        table.remove(urlSuffix, index)
    end
end

-- 清除参数集合
function CommunityMgr:clearCommunityUrlSuffix()
    urlSuffix = {}
end

-- 将参数para添加url参数表t中
function CommunityMgr:addUrlPara(t, key, para)
    local paraStr = key .. tostring(para)
    if not self.lastAccessUrl then
        -- 没有缓存url时，直接插入参数
        table.insert(t, paraStr)
    else
        if "token=" == key then
            if not string.match(self.lastAccessUrl, key) then
                -- 当前缓存url中没有token时，才添加token
                table.insert(t, paraStr)
            end
        else
            table.insert(t, paraStr)
        end
    end
end

-- 微社区是否打开
function CommunityMgr:isCommunityOpen()
    if GuideMgr:isIconExist(30)  then
        return true
    end

    return false
end

-- 是否需要播放微社区引导
function CommunityMgr:needCommunityGuide()
    if Me:getLevel() <= 40 then
        return true
    end

    return false
end

-- 获取微社区url官服,渠道服后缀
function CommunityMgr:getQuDaoSuffix()
    if ShareMgr:isOffice() then
        return COMMUNITY_URL_QD_SUFFIX.GF
    else
        return COMMUNITY_URL_QD_SUFFIX.QDF
    end
end

-- 获取微社区url新手引导后缀
function CommunityMgr:getCommunityUrlGuideSuffix()
    return COMMUNITY_URL_GUIDE_SUFFIX
end

function CommunityMgr:makeQueryString(data)
    return table.concat(data, "&")
end

-- 设置最后访问的地址
function CommunityMgr:setLastAcesss(url, time)
    self.lastAccessUrlTime = time
    if not string.isNilOrEmpty(url) then
        local subs = gf:split(url, "?")
        if not subs then return end

        self.lastAccessUrl = subs[1]
        local filtParas = {}
        if #subs == 2 then
            local paras = gf:split(subs[2], "&")
            for i = 1, #paras do
                if not URL_FILT_PARA_CFG[paras[i]] then
                    table.insert(filtParas, paras[i])
                end
            end
        end

        if #filtParas > 0 then
            self.lastAccessUrl = self.lastAccessUrl .. "?" .. table.concat(filtParas, "&")
        end
    end
end

function CommunityMgr:MSG_COMMUNITY_TOKEN(data)
    if token ~= data.token then
        -- token 变化了，按照与微社区的约定
        -- 下次打开微社区时只能访问主页面，不能访问上一次访问的 url 信息
        -- 故需要清除
        CommunityMgr.lastAccessUrl = nil
    end

    -- 清空token
    self:setToken()

    -- 刷新token
    if data.token then
        self:setToken(data.token)
    end

    -- 先移除需要过滤的参数
    for k, v in pairs(URL_FILT_PARA_CFG) do
        self:removeCommunityUrlSuffix(k)
    end

    local redDotType = Bitset.new(data.red_dot_type)
    if redDotType:isSet(2) then
        self:addCommunityUrlSuffix("daoxin_gift_redpoint=yes")
    end

    if redDotType:isSet(3) then
        self:addCommunityUrlSuffix("daoxin_progress_redpoint=yes")
    end

    if redDotType:isSet(1) or redDotType:isSet(4) then
        self:addCommunityUrlSuffix(COMMUNITY_URL_REDPOINT_SUFFIX)
    end

    -- 如果需要打开界面
    if needOpenDlg then

        if self.toBeOpenUrl then
            if self.toBeOpenUrl.type == "articleId" then
                self:openCommunityDlg(self.toBeOpenUrl.para)
            elseif self.toBeOpenUrl.type == "bbsvurl" then
                self:openCommunityDlgByUrl(self.toBeOpenUrl.para)
            end

            self.toBeOpenUrl = nil
        else
            self:askForOpenCommunityDlg()
        end
    end
end

function CommunityMgr:clearData()
    -- 清除 token 信息
    token = nil

    self:setPreLoadCommunityType(PRELOAD_COMMUNITY_TYPE.NONE)
    self:setPreLoadRedDotData(nil)

    -- 微社区地址换线不清除  WDSY-26675
    if not DistMgr:getIsSwichServer() then
        url = nil
        needOpenDlg = false
    end
end

function CommunityMgr:MSG_COMMUNITY_ADDRESS(data)
    self:setCommunityURL(data.address)
end

-- 登录排队时返回微社区的地址
function CommunityMgr:MSG_L_GET_COMMUNITY_ADDRESS(data)
    self:setCommunityURL(data.address)
end

MessageMgr:regist("MSG_COMMUNITY_TOKEN", CommunityMgr)
MessageMgr:regist("MSG_COMMUNITY_ADDRESS", CommunityMgr)
MessageMgr:regist("MSG_L_GET_COMMUNITY_ADDRESS", CommunityMgr)
