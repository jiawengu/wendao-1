-- oss.lua
-- Created by sujl, Sept/20/2017
-- 阿里oss云存储服务

require("core/sha1")
require("core/base64")

local oss = class('oss', function()
    return cc.Node:create()
end)

local BOUNDARY = "9431149156168"
local PNG_END = "\0\0\0\0\73\69\78\68\174\66\96\130"
local JPG_END = "\255\217"
local PNG_HEAD = "\137\80\78\71"
local JPG_HEAD = "\255\216\255"

local HTTP_HEADERS = {
    AUTHORIZATITION = 'Authorization',
    CACHE_CONTROL = 'Cache-Control',
    CONTENT_DISPOSITION = 'Content-Disposition',
    CONTENT_ENCODING = 'Content-Encoding',
    CONTENT_LENGTH = 'Content-Length',
    CONTENT_MD5 = 'Content-MD5',
    CONTENT_TYPE = 'Content-Type',
    DATE = 'Date',
    ETAG = 'ETag',
    EXPIRES = 'Expires',
    HOST = 'Host',
    LAST_MODIFIED = 'Last-modified',
    RANGE = 'Range',
    LOCATION = 'Location',
    USER_AGENT = 'User-Agent',
}

-- 字符串转数字串
local toByteStr
if not gf.toByteStr then
    toByteStr = function(str)
        local s = ""
        for i = 1, #str, 2 do
            s = s .. string.char(tonumber(string.format("0x%s", string.sub(str, i, i + 1))))
        end
        return s
    end
else
    local toByteStr = gf.toByteStr
end

-- 获取GMT时间
local function getGMTTime()
    local bt = os.time({ year = 1970, month = 1, day = 2, hour = 0, min = 0, sec = 0 }) - 24 * 60 * 60
    local gmt = os.time() + bt
    return gmt
end

-- 文件请求队列，全局管理，除非游戏推出，否则只在下载完成时析构
local fileReqs = {}

function unRegAllOSSFileReqs()
    if fileReqs then
        for _, v in pairs(fileReqs) do
            if v and 'function' == type(v.release) then
                v:release()
            end
        end
    end

    fileReqs = {}
end

-- 构造函数
function oss:ctor(cfg)
    self.cfg = cfg
    self.cfg.timeout = self.cfg.timeout or 10
    self.authorizationServer = self.cfg.authorizationServer
    self.reqs = {}  -- 正在处理的请求

    if self.cfg.AccessKeyId and self.cfg.AccessKeySecret then
        if not self.authorization then self.authorization = {} end
        self.authorization["AccessKeyId"] = self.cfg.AccessKeyId
        self.authorization["AccessKeySecret"] = self.cfg.AccessKeySecret
    end

    local function onNodeEvent(event)
        if "cleanup" == event then
            self:cleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function oss:cleanup()
    if self.reqs then
        for _, v in pairs(self.reqs) do
            if v then
                v:unregisterScriptHandler()
                v:release()
            end
        end

        self.reqs = nil
    end
end

function oss:regFileReq(req)
    req:retain()
    fileReqs[tostring(req)] = req
end

function oss:unRegFileReq(req, immediately)
    if req then
        if fileReqs then
            fileReqs[tostring(req)] = nil
        end
        if immediately then
            req:release()
        else
            local uiLayer = gf:getUILayer()
            if uiLayer then
                performWithDelay(gf:getUILayer(), function()
                    req:release()
                end, 0.1)
            end
        end
    end
end

function oss:useBucket(bukcetName)
    self.cfg.bucket = bukcetName
end

-- 签名
function oss:signature(stringToSign)
    local sig = hmac_sha1_binary(self.authorization["AccessKeySecret"], stringToSign)
    local sig_base64 = to_base64(sig)
    --local sigStr = gf:encodeURI(sig_base64)
    -- Log:I("sign: %s => %s", stringToSign, sig_base64)
    return sig_base64
end

-- 获取header对应key的信息
function oss:getHeader(headers, name)
    return headers[name] or headers[string.lower(name)]
end

-- 获取请求串
function oss:_getResource(params)
    local resource = '/'
    if params.bucket then resource = resource .. params.bucket .. '/' end
    if params.object then resource = resource .. params.object end

    return resource
end

-- 获取请求地址
function oss:_getReqUrl(params)
    local url = self.cfg.endpoint

    if self.cfg.bucket then
        url = self.cfg.bucket .. '.' .. url
    end

    if params.object then
        if '/' ~= string.sub(url, -1) then
            url = url .. '/' .. params.object
        else
            url = url .. params.object
        end
    end

    url = 'http://' .. url

    local subresAsQuery = {}
    if params.subres then
        if 'string' == type(params.subres) then
            table.insert(subresAsQuery, params.subres)
        elseif 'table' == type(params.subres) then
            if #(params.subres) > 0 then
                for i = 1, #(params.subres) do
                    table.insert(subresAsQuery, params.subres[i])
                end
            else
                for k, v in pairs(params.subres) do
                    table.insert(subresAsQuery, string.foramt("%s=%s", k, gf:encodeURI(v)))
                end
            end
        end
    end

    if #subresAsQuery > 0 then
        url = url .. "?" .. table.concat(subresAsQuery, '&')
    end

    return url
end

-- 认证请求
function oss:doAuthorization(method, resource, subres, headers)
    local params = {
        string.upper(method),
        headers['Content-Md5'] or '',
        self:getHeader(headers, 'Content-Type'),
        headers['x-oss-date'],
    }

    local ossHeaders = {}
    for k, v in pairs(headers) do
        local lkey = string.lower(k)
        if 1 == string.find(lkey, 'x%-oss%-') then
            ossHeaders[lkey] = ossHeaders[lkey] or {}
            table.insert(ossHeaders[lkey], v)
        end
    end

    local ossHeadersList = {}
    for k, v in pairs(ossHeaders) do
        table.insert(ossHeadersList, string.format("%s:%s", k, table.concat(v, ',')))
    end

    table.sort(ossHeadersList)
    table.insert(params, table.concat(ossHeadersList, '\n'))

    local resourceStr = ''
    resourceStr = resourceStr .. resource

    local subresList = {}
    if subres then
        if 'string' == type(subres) then
            table.insert(subresList, subres)
        elseif 'table' == type(subres) then
            if #subres > 0 then
                subresList = gf:deepCopy(subres)
            else
                for k, v in subres do
                    table.insert(subresList, string.format("%s=%s", k. v))
                end
            end
        end
    end

    if #subresList > 0 then
        table.sort(subresList)
        resourceStr = resourceStr .. '?' .. table.concat(subresList, '&')
    end

    -- Log:I('CanonicalizedResource: %s', resourceStr)

    table.insert(params, resourceStr)
    local stringToSign = table.concat(params, '\n')

    local auth = 'OSS ' .. self.authorization['AccessKeyId'] .. ':'
    return auth .. self:signature(stringToSign)
end

-- 创建http请求
function oss:createRequest(params)
    local headers = {
        ['x-oss-date'] = os.date("%a, %d %b %Y %X GMT", getGMTTime()),
        ['x-oss-user-agent'] = self.userAgent,
        ['User-Agent'] = self.userAgent,
    }

    if params.headers then
        for k, v in pairs(params.headers) do
            headers[k] = v
        end
    end

    if self.authorization["SecurityToken"] then
        headers['x-oss-security-token'] = self.authorization["SecurityToken"]
    end

    if not self:getHeader(headers, 'Content-Type') then
        headers['Content-Type'] = 'application/octet-stream'
    end

    if params.content then
        headers['Content-Md5'] = to_base64(toByteStr(gfGetMd5(params.content)))

        if not headers['Content-Length'] then
            headers['Content-Length'] = #(params.content)
        end
    end

    local authResource = self:_getResource(params)
    headers.authorization = self:doAuthorization(params.method, authResource, params.subres, headers)

    local url = self:_getReqUrl(params)
    local timeout = params.timeout or self.cfg.timeout
    local reqParams = {
        method = params.method,
        content = params.content,
        headers = headers,
        timeout = timeout,
    }

    return url, reqParams
end

-- 发起http请求
function oss:httpRequest(params, callback)
    local url, params = self:createRequest(params)

    local xhr = cc.XMLHttpRequest:new()
    self.reqs[tostring(xhr)] = xhr
    xhr:retain()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER
    xhr:open(params.method, url)

    if params.headers then
        for k, v in pairs(params.headers) do
            xhr:setRequestHeader(k, v)
        end
    end

    local delayAction
    delayAction = performWithDelay(self, function()
        -- 超时，返回
        callback()
        delayAction = nil
        xhr:unregisterScriptHandler()
        xhr:release()
        self.reqs[tostring(xhr)] = nil
    end, params.timeout)

    local function onReadyStateChange()
        -- Log:I("HTTP_RESPONSE from (" .. string.gsub(url, '%%', '%%%%') .. "):" .. xhr.statusText)
        if 'function' == type(callback) then
            if delayAction then
                self:stopAction(delayAction)
                delayAction = nil
            end
            callback({ status = xhr.statusText, response = xhr.response })
        end

        if self.reqs and self.reqs[tostring(xhr)] then
            xhr:release()
            self.reqs[tostring(xhr)] = nil
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(params.content)
    -- Log:I("Send http to(" .. string.gsub(url, '%%', '%%%%') .. ")")
end

-- 创建post请求数据
function oss:createPostRequest(params)
    local headers = {
        ['User-Agent'] = self.userAgent,
    }

    if params.headers then
        for k, v in pairs(params.headers) do
            headers[k] = v
        end
    end

    headers['Content-Type'] = 'multipart/form-data; boundary=' .. BOUNDARY

    local url = self:makeBaseAddr()
    if not string.isNilOrEmpty(self.cfg.upload) then
        url = url .. "/" .. self.cfg.upload
    end

    local timeout = params.timeout or self.cfg.timeout
    local reqParams = {
        method = params.method,
        content = self:createPostBody(params),
        headers = headers,
        timeout = timeout,
    }

    return url, reqParams
end

-- 创建post请求体
function oss:createPostBody(params)
    local textMap = {}
    textMap["key"] = params.object
    textMap["OSSAccessKeyId"] = self.authorization["AccessKeyId"]
    if self.authorization["Expiration"] then
        textMap["policy"] = to_base64(string.format("{\"expiration\": \"%s\",\"conditions\": [[\"content-length-range\", 0, 1073741824]]}", self.authorization["Expiration"]))  -- 104857600
    else
        textMap["policy"] = to_base64("{\"expiration\": \"2120-01-01T12:00:00.000Z\",\"conditions\": [[\"content-length-range\", 0, 1073741824]]}") -- 104857600
    end

    textMap["Signature"] = self:signature(textMap["policy"])
     if self.authorization["SecurityToken"] then
        textMap['x-oss-security-token'] = self.authorization["SecurityToken"]
    end

    local bodyMap = {}
    for k, v in pairs(textMap) do
        table.insert(bodyMap, '--' .. BOUNDARY)
        table.insert(bodyMap, string.format("Content-Disposition: form-data; name=\"%s\"\r\n", k))
        table.insert(bodyMap, v)
    end

    local contentType = self:getHeader(params.headers, 'Content-Type')
    if not contentType then
        contentType = 'application/octet-stream'
    end

    table.insert(bodyMap, '--' .. BOUNDARY)
    table.insert(bodyMap, string.format("Content-Disposition: form-data; name=\"file\"; filename=\"%s\"", params.fileName))
    table.insert(bodyMap, string.format("Content-Type: %s\r\n", contentType ))
    table.insert(bodyMap, params.content)

    table.insert(bodyMap, '--' .. BOUNDARY)
    table.insert(bodyMap, "Content-Disposition: form-data; name=\"submit\"\r\n")
    table.insert(bodyMap, "Upload to OSS")
    table.insert(bodyMap, '--' .. BOUNDARY .. '--')

    return table.concat(bodyMap, '\r\n')
end

-- 发起post请求
function oss:httpPostRequest(params, callback)
    local url, params = self:createPostRequest(params)

    local xhr = cc.XMLHttpRequest:new()
    self.reqs[tostring(xhr)] = xhr
    xhr:retain()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open(params.method, url)
    Log:I("oss:httpPostRequest=>%s", url)

    if params.headers then
        for k, v in pairs(params.headers) do
            xhr:setRequestHeader(k, v)
        end
    end

    local delayAction
    delayAction = performWithDelay(self, function()
        -- 超时，返回
        xhr:unregisterScriptHandler()
        callback()
        delayAction = nil
        xhr:release()
        self.reqs[tostring(xhr)] = nil
        callback = nil
    end, params.timeout)

    local function onReadyStateChange()
        -- Log:I("HTTP_RESPONSE from (" .. string.gsub(url, '%%', '%%%%') .. "):" .. xhr.statusText)
        if 'function' == type(callback) then
            if delayAction then
                self:stopAction(delayAction)
                delayAction = nil
            end
            Log:D("oss:httpPostRequest=>%s", tostring(xhr.response))
            callback({ status = xhr.statusText, response = xhr.response })
        end

        if self.reqs and self.reqs[tostring(xhr)] then
            xhr:release()
            self.reqs[tostring(xhr)] = nil
        end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(params.content)
    -- Log:I("Send http to(" .. string.gsub(url, '%%', '%%%%') .. ")")
end

-- 申请临时凭证
function oss:requestAuthorization(callback)
    if not self.authCallbacks then
        self.authCallbacks = {}
    end

    table.insert(self.authCallbacks, callback)
    if 'function' == type(self.authorizationServer) then
        self.authorizationServer(self)
    end
end

function oss:refreshAuthorization(data)
    if not data or 'string' ~= type(data) or not self.authCallbacks then
        return
    end

    local responseText = string.gsub(data, '\\/', '/')
    if string.isNilOrEmpty(responseText) then return end
    self.authorization = json.decode(responseText)
    local expiration = self.authorization['Expiration']
    local y, m, d, hh, mm, ss = string.match(expiration, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
    if not y or not m or not d or not hh or not mm or not ss then
        -- 不是合法数据，清除权限信息
        self.authorization = nil
    end

    for i = 1, #self.authCallbacks do
        local func = self.authCallbacks[i]
        if func then
            func()
        end
    end

    self.authCallbacks = {}
end

-- 检查凭证有效性
function oss:checkStsValid(callback)
    if not self.authorization then
        self:requestAuthorization(callback)
        return
    end

    if self.authorization['Expiration'] then
        local expiration = self.authorization['Expiration']
        local y, m, d, hh, mm, ss = string.match(expiration, "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)Z")
        if not y or not m or not d or not hh or not mm or not ss then
            self.authorization = nil
            self:requestAuthorization(callback)
            return
        end

        local t = os.time({year = y, month = m, day = d, hour = hh, min = mm, sec = ss})
        if getGMTTime() > t + 60 then   -- 至少需要1min的有效期
            self.authorization = nil
            self:requestAuthorization(callback)
            return
        end
    end

    callback()
end

-- 生成请求参数
function oss:_objectRequestParams(method, name, options)
    if not self.cfg.bucket then
        return
    end

    options = options or {}
    local params = {
        object = name,
        bucket = self.cfg.bucket,
        method = method,
        subres = options and options.subres,
        timeount = options and options.timeount,
        ctx = options and options.ctx
    }

    if options.headers then
        params.headers = options.headers
    end

    return params
end

function oss:_convertMetaToHeaders(meta, headers)
    if not meta then
        return
    end

    for k, v in pairs(meta) do
        headers['x-oss-meta-' .. k] = v
    end
end

-- 上传文件
function oss:put(callback, objectName, filePath, options)
    if not gf:isFileExist(filePath) then
        Log:I("Can't found the file:%s", filePath)
        callback()
        return
    end

    local f = io.open(filePath, 'rb')
    local data = f:read("*a")
    f:close()

    self:putText(callback, objectName, data, options)
end

-- 上传文本
function oss:putText(callback, objectName, content, options)
    self:checkStsValid(function()
        if not self.authorization then
            callback()
            return
        end

        options = options or {}
        options.headers = options.header or {}
        self:_convertMetaToHeaders(options.meta, options.headers)

        local method = options.method or 'PUT'
        local params = self:_objectRequestParams(method, objectName, options)
        params.mime = options.mime
        params.content = content

        self:httpRequest(params, callback)
    end)
end

-- 下载文件
function oss:getText(callback, objectName, options)
    self:checkStsValid(function()
        if not self.authorization then
            callback()
            return
        end

        options = options or {}
        if options.process then
            options.subres = options.subres or {}
            options.subres['x-oss-process'] = options.process;
        end

        local params = self:_objectRequestParams('GET', objectName, options)
        self:httpRequest(params, callback)
    end)
end

-- 下载文件到本地文件
function oss:get(callback, objectName, filePath, options)
    self:getText(function(data)
        if not data then
            callback()
            return
        end

        -- 尝试创建文件目录
        if gfSaveFile("", filePath) then
            filePath = cc.FileUtils:getInstance():getWritablePath() .. filePath
            local fileData = data.response
            local size = table.getn(fileData)
            -- Log:I("write file:%s(%d)", filePath, size)
            local f = io.open(filePath, 'wb')
            for i = 1, size do
                f:write(string.char(fileData[i]))
            end
            f:close()
            -- Log:I("write file:%s(%d)", filePath, #(data.response))
            -- Log:I("%s", table.concat(fileData, ''))
            callback(objectName, filePath)
        else
            callback()
        end
    end, objectName, options)
end

-- post上传文本
function oss:postText(callback, objectName, content, options)
    self:checkStsValid(function()
        if not self.authorization then
            callback()
            return
        end

        options = options or {}
        options.headers = options.header or {}
        self:_convertMetaToHeaders(options.meta, options.headers)

        local method = 'POST'
        local params = self:_objectRequestParams(method, objectName, options)
        params.mime = options.mime
        params.content = content
        params.fileName = objectName

        self:httpPostRequest(params, callback)
    end)
end

-- post上传本地文本
function oss:post(callback, objectName, filePath, options)
    if not gf:isFileExist(filePath) then
        Log:I("Can't found the file:%s", filePath)
        callback()
        return
    end

    local f = io.open(filePath, 'rb')
    local data = f:read("*a")
    f:close()

    self:postText(callback, objectName, data, options)
end

-- 通过地址访问

-- 生成访问资源
function oss:buildCanonicalizedResource(bucketName, objectKey, params)
    local resourcePath
    if not bucketName and not objectKey then
        resourcePath = '/'
    elseif not objectKey then
        resourcePath = '/' .. bucketName .. '/'
    else
        resourcePath = '/' .. bucketName .. '/' .. objectKey
    end

    if params then
        local t = {}
        for k, v in pairs(params) do
            table.insert(t, string.format("%s=%s", k, v))
        end
        table.sort(t)
        local str = table.concat(t, '&')
        if str and #str > 0 then
            resourcePath = resourcePath .. '?' .. str
        end
    end

    return resourcePath
end

-- 生成地址校验字符串
function oss:makeSignRequestStr(accessKeySecret, msg)
    local headers = msg.headers
    local verb = headers.method
    local contentMd5 = headers[HTTP_HEADERS.CONTENT_MD5]
    local contentType = headers[HTTP_HEADERS.CONTENT_TYPE]
    local expiresDate = msg[HTTP_HEADERS.EXPIRES]

    local ossHeaders = {}
    for k, v in pairs(headers) do
        local index = string.find(k, 'x-oss-')
        if 1 == index then
            ossHeaders[k] = v
        end
    end

    local res = self:buildCanonicalizedResource(msg.bucketName, msg.objectName, msg.params)

    -- 生成签名信息
    local function getSignStr(accessKeySecret, verb, content, contentType, expires, ossHeaders, res)
        local t = {}
        table.insert(t, verb)
        if content then
            table.insert(t, gfGetMd5(content))
        else
            table.insert(t, '')
        end

        if contentType then
            table.insert(t, contentType)
        else
            table.insert(t, '')
        end
        table.insert(t, expires)

        --[[
        local keys = {}
        for k, v in pairs(ossHeaders) do
            table.insert(keys, k)
        end
        table.sort(keys)
        local headers = {}
        for i = 1, #keys do
            table.insert(headers, string.format("%s:%s", keys[i], ossHeaders[ keys[i] ]))
        end
        table.insert(t, table.concat(headers, '\n'))
        ]]

        table.insert(t, res)

        local str = table.concat(t, '\n')
        return str
    end

    return getSignStr(accessKeySecret, verb, contentMd5, contentType, expiresDate, ossHeaders, res)
end

-- 生成地址校验签名
function oss:signRequest(accessKeySecret, msg)
    local headers = msg.headers
    local verb = headers.method
    local contentMd5 = headers[HTTP_HEADERS.CONTENT_MD5]
    local contentType = headers[HTTP_HEADERS.CONTENT_TYPE]
    local expiresDate = msg[HTTP_HEADERS.EXPIRES]

    local ossHeaders = {}
    for k, v in pairs(headers) do
        local index = string.find(k, 'x-oss-')
        if 1 == index then
            ossHeaders[k] = v
        end
    end

    local res = self:buildCanonicalizedResource(msg.bucketName, msg.objectName, msg.params)

    -- 生成签名信息
    local function sign(str)
        local sig = hmac_sha1_binary(accessKeySecret, str)
        local sig_base64 = to_base64(sig)
        local sigStr = gf:encodeURI(sig_base64)
        -- Log:I("sign: \n%s => %s(%s)", str, sigStr, sig_base64)
        return sigStr
    end

    local signStr = sign(self:getSignStr(accessKeySecret, msg))
    return signStr
end

-- 生成访问路径
function oss:buildAddress(accessKeyId, accessKeySecret, msg, sign)
    local baseAddr = msg.baseAddr
    sign = sign or self:signRequest(accessKeySecret, msg)
    local params = {}

    if msg.params then
        for k, v in pairs(msg.params) do
            table.insert(params, string.format("%s=%s", k, gf:encodeURI(v)))
        end
    end

    baseAddr = baseAddr .. '/' .. msg.objectName

    table.insert(params, string.format("OSSAccessKeyId=%s", accessKeyId))
    table.insert(params, string.format("Expires=%s", msg[HTTP_HEADERS.EXPIRES]))
    table.insert(params, string.format("Signature=%s", sign))

    local addr = string.format("%s?%s", baseAddr, table.concat(params, '&'))
    return addr
end

--[[
function oss:getObjectUrl(callback, objectName, timeout)
    local xhr = cc.XMLHttpRequest:new()
    self.reqs[tostring(xhr)] = xhr
    xhr:retain()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', 'http://crm.leiting.com/game/get_aliyun_object_url.do')

    local delayAction
    delayAction = performWithDelay(self, function()
        -- 超时，返回
        callback()
        delayAction = nil
        xhr:unregisterScriptHandler()
        xhr:release()
        self.reqs[tostring(xhr)] = nil
    end, timeout)

    local function onReadyStateChange()
        -- Log:I("HTTP_RESPONSE:" .. string.gsub(tostring(xhr.response), '%%', '%%%%'))
        if 'function' == type(callback) then
            if delayAction then
                self:stopAction(delayAction)
                delayAction = nil
            end

            local jsonStr = xhr.response
            local msg = json.decode(jsonStr)
            if 'success' == msg.status then
                callback(msg.message)
            else
                callback()
            end
        end

        if self.reqs and self.reqs[tostring(xhr)] then
            xhr:release()
            self.reqs[tostring(xhr)] = nil
        end
    end

    local content = string.format("gameCode=%s&objectName=%s&sign=%s", "wd", objectName, string.lower(gfGetMd5(string.format("%s%%%s%%%s", 'wd', objectName, 'leiting!@#123'))))
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send(content)
end
]]

-- 生成地址
function oss:makeBaseAddr()
    local url = "http://"
    if not string.isNilOrEmpty(self.cfg.bucket) then
        url = url .. self.cfg.bucket .. '.'
    end
    url = url .. self.cfg.endpoint
    return url
end

function oss:getObjectUrlEx(callback, objectName, options)
    local duration = options and options.duration or 120
    self:checkStsValid(function()
        if not self.authorization then
            callback()
            return
        end

        local msg = {
            baseAddr = self:makeBaseAddr(),
            ['Expires'] = os.time() + duration,
            headers = {
                method = 'GET',
            },
            params = {
                ["security-token"] = self.authorization["SecurityToken"],
                ['x-oss-process'] = options and options.process,
            },

            bucketName = self.cfg.bucket,
            objectName = objectName
        }


        local addr = self:buildAddress(self.authorization["AccessKeyId"], self.authorization["AccessKeySecret"], msg, gf:encodeURI(gfHmacSha1Base64(self.authorization["AccessKeySecret"], self:makeSignRequestStr(self.authorization["AccessKeySecret"], msg))))
        callback(addr)
    end)
end

-- 通过文件头检测是否有效 , 当前仅png和jpg
function oss:checkFileValidity(filePath)
    if not gf:isFileExist(filePath) then return false end
    local f = io.open(filePath, "rb")
    local ext = gf:getFileExt(filePath)
    local len = f:seek("set")
    local readnum
    if "jpg" == ext then readnum = 3
    elseif "png" == ext then readnum = 4
    else return true end    -- 非png和jpg，可能是amr文件
    local headCode = f:read(readnum)
    f:close()
    if string.isNilOrEmpty(headCode) then
        -- 没有读到内容
        return false
    elseif "jpg" == ext then
        return headCode == JPG_HEAD
    elseif "png" == ext then
        return headCode == PNG_HEAD
    end

    return false
end

-- 通过地址获取资源(支持从服务器获取校验信息)
function oss:urlgetex(callback, objectName, filePath, options)
    local duration = options and options.duration or 120

    self:getObjectUrlEx(function(url)
        local addr = url
        local httpFile = HttpFile:create()

        if httpFile then
            self:regFileReq(httpFile)

            gfSaveFile("", filePath)
            local filePath = cc.FileUtils:getInstance():getWritablePath() .. filePath

            -- 回调请求
            local function _callback(state, value)
                if not fileReqs or not fileReqs[tostring(httpFile)] or not self.reqs then return end    -- 已经析构没有数据了，直接返回，不需要处理

                if 0 == state then
                    performWithDelay(self, function()
                        if oss:checkFileValidity(filePath) then
                            callback(filePath)
                        else
                            os.remove(filePath)
                            callback()
                        end
                    end, 0)

                    -- 已经完成作业，释放对象
                    self:unRegFileReq(httpFile, true)
                elseif 2 == state then
                    callback()
                    os.remove(filePath)

                    -- 已经完成作业，释放对象
                    self:unRegFileReq(httpFile, true)
                end
            end

            httpFile:setDelegate(_callback)
            httpFile:downloadFile(addr, filePath)
        end
    end, objectName, options)
end

return oss
