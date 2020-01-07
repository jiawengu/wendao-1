-- BlogAddressDlg.lua
-- Created by sujl, Sept/25/2017
-- 空间地址界面

local BlogAddressDlg = Singleton("BlogAddressDlg", Dialog)

local platform = cc.Application:getInstance():getTargetPlatform()

local LENLIMIT = 12

-- 定位最大时间限制
local LOCATION_LISTEN_MAX_TIME = 15

function BlogAddressDlg:init(gid)
    self:setCtrlVisible("AddressPanel1", false)
    self:setCtrlVisible("AddressPanel2", false)
    local ver1, ver2 = gf:getVersionValue(require("PlatformConfig").CUR_VERSION)
    self.rootName = nil
    if gf:gfIsFuncEnabled(FUNCTION_ID.LOCATION_SERVICE) or ver1 > "2.016" or (ver1 == "2.016" and ver2 >= "1214") then
        -- 强更功能：android在1214后才有，ios的在1221后才有，但ios的没有内侧区，暂时不处理
        self.rootName = "AddressPanel2"
    else
        self.rootName = "AddressPanel1"
    end
    
    self:setCtrlVisible(self.rootName, true)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("DelButton", self.onDelButton, self.rootName)
    self:bindListener("GpsButton", self.onGpsButton, "AddressPanel2")

    self.updateLocationFunc = function()
        GpsMgr:stopLocationListener()
        if self.updateLocationFunc then
            EventDispatcher:removeEventListener("updateLocation", self.updateLocationFunc)
        end
        
        local latLng = GpsMgr:getLocation()
        if latLng and latLng.latitude and latLng.longitude then
            GpsMgr:getCityNameByLatAndLng(latLng.latitude, latLng.longitude, function(flag, info)
                if not DlgMgr:isDlgOpened(self.name) then
                    -- 回调回来，界面已经被关闭了，则不进行后续处理
                    return
                end

                self:clearSchedule()
                self:setCtrlEnabled("GpsButton", true, "AddressPanel2")
                self:setCtrlVisible("AddressLabel", false, "AddressPanel2")
                self.newEdit:setVisible(true)
                
                if flag then
                    local cityInfo = GpsMgr:convertJsonInfoToCity(info)
                    if cityInfo and cityInfo ~= "" then
                        self.newEdit:setText(BlogMgr:getLocationShowStr(cityInfo))
                        self.curLocation = cityInfo
                        return
                    end
                end

                gf:ShowSmallTips(CHS[7120038])
            end)
        else
            self:doWhenLocationFail()

            gf:ShowSmallTips(CHS[7120038])
        end
    end
    
    self:setCtrlVisible("NoneLabel", false, self.rootName)
    self.gid = gid

    self.newEdit = self:createEditBox("AddressPanel", self.rootName, nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newEditString = self.newEdit:getText()
            if newEditString ~= BlogMgr:getLocationShowStr(self.curLocation) then
                if gf:getTextLength(newEditString) > LENLIMIT then
                    newEditString = gf:subString(newEditString, LENLIMIT)
                    self.newEdit:setText(newEditString)
                    gf:ShowSmallTips(CHS[4000224])
                end

                self.curLocation = nil
            end

            self:setCtrlVisible("DelButton", newEditString ~= "", self.rootName)
        end
    end)

    self.newEdit:setPlaceHolder(CHS[4100649])   -- 点击输入
    self.newEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newEdit:setPlaceholderFont(CHS[3003597], 21)
    self.newEdit:setFont(CHS[3003597], 21)
    self.newEdit:setFontColor(COLOR3.TEXT_DEFAULT)
    local userData = BlogMgr:getUserDataByGid(gid)
    self.newEdit:setText(BlogMgr:getLocationShowStr(userData.location))
    self:setCtrlVisible("DelButton", not string.isNilOrEmpty(userData.location), self.rootName)
    
    if not string.isNilOrEmpty(userData.location) then
        self.curLocation = userData.location
    end
end

function BlogAddressDlg:onConfirmButton(sender, eventType)
    local str = self.newEdit:getText()
    local userData = BlogMgr:getUserDataByGid(self.gid)
    if BlogMgr:getLocationShowStr(self.curLocation) == str then
        -- 定位信息不检测敏感词及长度
        str = self.curLocation
    else
        local filtTextStr = gfFiltrate(str, true)
        if not string.isNilOrEmpty(filtTextStr) then
            gf:confirm(CHS[2000426], function()
                self.newEdit:setText(filtTextStr)
                gf:ShowSmallTips(CHS[2000427])
                ChatMgr:sendMiscMsg(CHS[2000428])
            end, nil, nil, nil, nil, nil, true)
            return
        end
        
        if gf:getTextLength(str) > LENLIMIT then
            str = gf:subString(str, LENLIMIT)
            self.newEdit:setText(str)
            gf:ShowSmallTips(CHS[5420287])
            return
        end
    end
    
    if str == userData.location then
        self:onCloseButton()
        return
    end


    gf:CmdToServer('CMD_BLOG_CHANGE_LOCATION', { location = str })
    self:onCloseButton()
end

function BlogAddressDlg:cleanup()
    self:clearSchedule()
    GpsMgr:stopLocationListener()

    if self.updateLocationFunc then
        EventDispatcher:removeEventListener("updateLocation", self.updateLocationFunc)
        self.updateLocationFunc = nil
    end

    self.newEdit = nil
end

function BlogAddressDlg:onDelButton(sender, eventType)
    self.curLocation = nil
    self.newEdit:setText("")
    self:setCtrlVisible("DelButton", false, self.rootName)
end

function BlogAddressDlg:onGpsButton(sender, eventType)
    if GpsMgr:tryOpenGpsLocation(self.updateLocationFunc) then
        -- 定位开启成功
        self.newEdit:setVisible(false)
        self:setCtrlEnabled("GpsButton", false, "AddressPanel2")
        self:startLocationCountDown()
    end
end

-- 定位失败时对界面的处理
function BlogAddressDlg:doWhenLocationFail()
    self:clearSchedule()
    self:setCtrlEnabled("GpsButton", true, "AddressPanel2")
    self:setCtrlVisible("AddressLabel", false, "AddressPanel2")
    self.newEdit:setVisible(true)
    self:setCtrlVisible("DelButton", self.newEdit:getText() ~= "", "AddressPanel2")
end

-- 开启定位文字效果
function BlogAddressDlg:startLocationCountDown()
    self:setLabelText("AddressLabel", "", "AddressPanel2")
    self:setCtrlVisible("AddressLabel", true, "AddressPanel2")
    self:setCtrlVisible("DelButton", false, "AddressPanel2")
    local pointStr = {[0] = "", [1] = ".", [2] = "..", [3] = "..."}
    local startIndex = 0
    local locationStartTime = gfGetTickCount()
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            local pointNum = startIndex % 4
            self:setLabelText("AddressLabel", CHS[7120039] .. pointStr[pointNum], "AddressPanel2")
            startIndex = startIndex + 1

            if gfGetTickCount() - locationStartTime >= 1000 * LOCATION_LISTEN_MAX_TIME then
                -- 定位时间到上限，则认为定位失败
                GpsMgr:stopLocationListener()
                if self.updateLocationFunc then
                    EventDispatcher:removeEventListener("updateLocation", self.updateLocationFunc)
                end

                self:doWhenLocationFail()

                gf:ShowSmallTips(CHS[7120038])
            end
        end, 0.2)
    end
end

-- 停止倒计时
function BlogAddressDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end
end

return BlogAddressDlg