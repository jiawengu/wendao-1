-- GpsMgr.lua
-- created by lixh2 Dec/09/2017
-- 定位GPS管理器

local platform = cc.Application:getInstance():getTargetPlatform()
local json = require("json")

local OTHER_COUNTRY_NAME_MAP = require(ResMgr:getCfgPath('OtherCountryMap.lua'))

-- 地球平均半径(km)
local EARTH_AVERAGE_R = 6378.140

GpsMgr = Singleton()

-- 位置信息latitude,longitude
GpsMgr.location = {}

local callPlatFormFun = function(func)
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()Ljava/lang/String;"
        local args = {}
        local ok, ret = luaj.callStaticMethod(className, func, args, sig)
        if ok then
            return ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require("luaoc")
        local ok, ret = luaoc.callStaticMethod('AppController', func)
        if ok then
            return ret
        end
    end
end

-- 开始GPS定位监听
-- type = 1(gps耗电，时间慢，但准确) type = 2(wifi不耗电，快，但没那么准)
-- acc:安卓为时间  6000(6秒)  IOS为精确度: 1,2,3,4,5,6精确度递减，默认使用精确模式2
-- dis:为距离，用户移动100米，会再次调用定位更新位置
-- ret: 安卓下返回bool标记是否成功
-- ret: ios下返回字符串：SUCCESS(开启成功) NOTALLOW(权限不允许) NOSERVICE(设备没开启服务)
function GpsMgr:startLocationListener(acc, dis, type)
    self.startListenLocation = false

    local args = {}
    local ok, ret
    if platform == cc.PLATFORM_OS_ANDROID then
        args[1] = type
        args[2] = acc
        args[3] = dis
        local luaj = require('luaj')
        ok, ret = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', "startLocationListener", args, "(III)Z")
        if ok then
            self.startListenLocation = ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        args = {distance = dis, accuracy = acc}
        local luaoc = require("luaoc")
        ok, ret = luaoc.callStaticMethod('AppController', "startLocationListener", args)
        if ok then
            if ret == "SUCCESS" then
                self.startListenLocation = true
            end
        end
    end

    return ret
end

-- 停止GPS定位监听
function GpsMgr:stopLocationListener()
    if not self.startListenLocation then
        return
    end

    callPlatFormFun("stopLocationListener")
    self.startListenLocation = nil
end

-- 获取判断
-- type = 1 : gps  type = 2 : wifi
function GpsMgr:isProviderEnableByType(t)
    local args = {}
    args[1] = t
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local ok, v = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', "isProviderEnableByType", args, "(I)Z")
        if ok then
            return v
        end
    end
end

-- 获取安卓可用的定位服务
-- 传入type时，如果type可用，优先返回type，否则优先wifi,再gps
function GpsMgr:getAndroidEnabelProviderByType(type)
    if type then
        if type == "gps" then
            if GpsMgr:isProviderEnableByType(1) then
                return 1
            end
        end

        if type == "wifi" then
            if GpsMgr:isProviderEnableByType(2) then
                return 2
            end
        end
    end

    if GpsMgr:isProviderEnableByType(2) then
        return 2
    end

    if GpsMgr:isProviderEnableByType(1) then
        return 1
    end

    return 0
end

-- 获取位置经纬度
-- type = 1 : gps  type = 2 : wifi
-- 安卓下的返回值v: (1) "ProviderDisable" ： 当前类型服务不可用   (2) "NoneLocation" ： 有服务，但该服务没有获取到位置
--                 (3) "AppNotLive" ： app已经被关闭     (4) "Latitude" + 纬度 + "Longitude" + 经度 ： 经纬度信息
-- ios下不可用
function GpsMgr:getLastKnowLocationByType(type)
    local args = {}
    args[1] = type
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local ok, v = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', "getLastKnowLocationByType", args, "(I)Ljava/lang/String;")
        if ok then
            return v
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
    end
end

-- IOS请求打开定位权限
-- 返回值：LOWTO8.0(8.0以下，无需主动申请权限) DENIED(此状态表明用户对定位已开启永不，申请也没用)
--        8.0REQUEST(权限状态为 restrict,notDetermined时申请成功)，DONTNEED(无需申请权限)
function GpsMgr:requstIOSLocationPermisson()
    if platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require("luaoc")
        local ok, ret = luaoc.callStaticMethod('AppController', "requestLocationServiceAuthorization")
        if ok then
            return ret
        end
    end
end

-- 跳转到定位设置见面：安卓跳转，ios提示
function GpsMgr:gotoSettingOrShowTips()
    if gf:isAndroid() then
        if not gf:gfIsFuncEnabled(FUNCTION_ID.LOCATION_SERVICE) then
            DlgMgr:openDlgEx("RemindDlg", CHS[7120040])
            return
        end

        gf:confirmEx(CHS[2100138], CHS[2100142], function()
            DeviceMgr:startActivityByIntent("android.settings.LOCATION_SOURCE_SETTINGS")
        end, CHS[2100143], function() end)
    elseif gf:isIos() then
        DlgMgr:openDlgEx("RemindDlg", CHS[2100139])
    end
end

-- 开始定位
function GpsMgr:tryOpenGpsLocation(callback, notTip)
    if platform == cc.PLATFORM_OS_ANDROID then
        local providerType = GpsMgr:getAndroidEnabelProviderByType("wifi")
        if 0 == providerType then
            -- 定位服务关闭(总开关)
            if not notTip then
                GpsMgr:gotoSettingOrShowTips()
            end

            return
        end

        local permission = "GPS"
        --[[
        if not gf:checkPermission(permission) then
            -- 应用定位权限被关闭
            gf:gotoSetting(permission)
            return
        end
        ]]

        gf:checkPermission(permission, "GpsMgr", function()
            EventDispatcher:addEventListener("updateLocation",  callback)
            if GpsMgr:isProviderEnableByType(2) then
                GpsMgr:startLocationListener(3000, 1, 2)
            end

            if GpsMgr:isProviderEnableByType(1) then
                GpsMgr:startLocationListener(3000, 1, 1)
            end
        end, function()
            -- 应用定位权限被关闭
            gf:gotoSetting(permission)
        end)
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local ret = GpsMgr:startLocationListener(2, 1)
        if ret == "SUCCESS" then
            EventDispatcher:addEventListener("updateLocation",  callback)
        else
            if ret== "NOSERVICE" then
                if not notTip then
                    GpsMgr:gotoSettingOrShowTips()
                end
            else
                if ret == "NOTALLOW" then
                    local requestRet = GpsMgr:requstIOSLocationPermisson()
                    if requestRet == "DENIED" then
                        if not notTip then
                            GpsMgr:gotoSettingOrShowTips()
                        end
                    end
                end
            end

            return
        end
    else
        return
    end

    return true
end

-- 更新GPS定位信息
function postGpsLocationChanged(result)
    if type(result) ~= "string" then return end

    if result == "getLocationFail" then
        -- ios下单次定位可能失败，暂时不用管，方便以后如果有用到失败次数统计
        return
    end

    local lat, lng = string.match(result, "(.+)|(.+)")
    local gpsLocation = {latitude = tonumber(lat), longitude = tonumber(lng)}
    GpsMgr:setLocation(gpsLocation)

    EventDispatcher:dispatchEvent("updateLocation")
    -- gf:ShowSmallTips("定位信息回来了！为 ：" .. result)
end

-- 设置GPS位置信息
function GpsMgr:setLocation(location)
    self.location = {}
    self.location = location
end

-- 获取GPS位置信息
function GpsMgr:getLocation()
    return self.location
end

-- 清除延时操作使用的节点
function GpsMgr:clearDelayNode()
    if self.uiLayer then
        self.uiLayer:release()
        self.uiLayer = nil
    end
end

-- 清除数据
function GpsMgr:clearData()
    GpsMgr:clearDelayNode()
end

-- 根据经纬度获取城市
-- lat, lng : 纬度, 经度 (支持多组，但传list的时候需要保证顺序，暂时我们需求没用到多组，但接口已支持并测试完毕)
-- callback(isOk, info) : isok(是否请求数据成功)  info(请求数据成功时，具体城市信息)
function GpsMgr:getCityNameByLatAndLng(lat, lng, callback)
    local url = ""
    local cookie = ""
    local location = ""
    local gameCode = 'wd'
    local batch = "false"
    if type(lat) == 'table' and type(lng) == 'table' then
        -- 多组数据
        for i = 1, #lat do
            lat[i] = math.floor(lat[i] * 1000) / 1000
            lng[i] = math.floor(lng[i] * 1000) / 1000
            location = location .. lat[i] .. "," .. lng[i]
            if i < #lat then
                location = location .. "|"
            end
        end

        batch = "true"
        cookie = gf:dealWithGpsCookie(gameCode, location, batch)
        url = GPS_CONFIG.DEFAULT_PLAT_U .. string.format(CHS[7120057], gameCode, location, batch, cookie)
    else
        lat = math.floor(lat * 1000) / 1000
        lng = math.floor(lng * 1000) / 1000
        location = lat .. "," .. lng
        cookie = gf:dealWithGpsCookie(gameCode, location)
        url = GPS_CONFIG.DEFAULT_PLAT_U .. string.format(CHS[7120056], gameCode, location, cookie)
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('GET', url, true)
    if not self.uiLayer then
        self.uiLayer =  gf:getUILayer()
        self.uiLayer:retain()
    end

    local delayAction
    delayAction = performWithDelay(self.uiLayer, function()
        if xhr then
            callback(false)
        end

        xhr = nil
        delayAction = nil
    end, 10)

    local function onReadyStateChange()
        if delayAction and self.uiLayer then self.uiLayer:stopAction(delayAction) end

        if not xhr then
            callback(false)
            return
        end

        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
        local info = ""
        local r, e = pcall(function()
            -- WDSY-30323，网络原因，返回的数据可能不能正常解析
            info = json.decode(xhr.response)
        end)

        if not r then
            -- 解析失败时，直接回调告知失败
            callback(false)
            return
        end

        callback(true, info)

        Log:I("CityInfo: " .. tostringex(info))
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

-- 根据两地经纬度,算距离,返回值单位(米)
function GpsMgr:getDistanceByLatLng(lat1, lng1, lat2, lng2)
    local radLat1 = math.rad(lat1)
    local radLat2 = math.rad(lat2)
    local la = radLat1 - radLat2
    local lb = math.rad(lng1) - math.rad(lng2)
    local s = 2 * math.asin(math.sqrt(math.pow(math.sin(la / 2.0), 2) + math.cos(radLat1) * math.cos(radLat2) * math.pow(math.sin(lb / 2.0), 2)))
    return s * EARTH_AVERAGE_R * 1000;
end

-- 经纬度信息转化为城市信息
function GpsMgr:convertJsonInfoToCity(info)
    if type(info) ~= 'table' then
        return
    end

    local ret = ""
    if info.status == 0 then
        -- 成功时解析城市数据
        if info.areas then
            local detailInfo = info.areas
            local ret = {}
            for i = 1, #detailInfo do
                local showInfo = self:getLocationForShow(detailInfo[i].country, detailInfo[i].province, detailInfo[i].city)
                table.insert(ret, showInfo)
            end

            return ret
        else
            local detailInfo = info.result.addressComponent
            return self:getLocationForShow(detailInfo.country, detailInfo.province, detailInfo.city)
        end
    else
        -- 失败时打印失败信息
        Log:I(info.message)
        return ret
    end
end

-- 经纬度信息转化为城市信息
function GpsMgr:getLocationForShow(country, province, city)
    if country == CHS[7120032] then
        local ret = ""
        if string.match(province, CHS[7120033]) then
            -- 新疆，西藏，内蒙古，宁夏，广西壮族自治区特殊处理
            province = string.match(province, CHS[7120033])
            province = string.match(province, CHS[7120034]) or province
            province = string.match(province, CHS[7120035]) or province
            province = string.match(province, CHS[7120036]) or province
            ret = province
        elseif string.match(province, CHS[7150029]) or string.match(province, CHS[7150030]) or
            string.match(province, CHS[7150031]) or string.match(province, CHS[7150032]) then
            -- 北京，天津，上海，重庆，直辖市特殊处理
            province = string.match(province, CHS[7150029]) or string.match(province, CHS[7150030]) or
                string.match(province, CHS[7150031]) or string.match(province, CHS[7150032])
            ret = province
        elseif string.match(province, CHS[7120055]) then
            -- 香港，澳门特别行政区处理
            province = string.match(province , CHS[7120055])
            ret = CHS[7120032] .. province
        else
            -- 其他省份，需要精确到下一级城市
            if string.match(province, CHS[7120037]) then
                province = string.match(province, CHS[7120037])
            end

            if string.match(city, CHS[7150033]) then
                city = string.match(city, CHS[7150033])
            end

            -- 台湾省处理为：中国台湾
            if province == CHS[5420275] then
                ret = CHS[7120032] .. province
            else
                ret = ret .. province .. city
            end
        end

        return ret
    else
        -- 国外直接返回国家名
        if OTHER_COUNTRY_NAME_MAP[country] then
            return OTHER_COUNTRY_NAME_MAP[country]
        else
            return country
        end
    end
end

