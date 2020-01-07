-- LoginForbidSimulatorDlg.lua
-- Created by sujl, Nov/1/2017
-- 禁止模拟器登录界面

local LoginForbidSimulatorDlg = Singleton("LoginForbidSimulatorDlg", Dialog)

local PLATFORM_CONFIG = require("PlatformConfig")

local TYPE2ICON = {
    ["tel"] = { icon = ResMgr.ui.service_tel, text = CHS[2100127] },
    ["qq"] = { icon = ResMgr.ui.service_qq, text = CHS[2100128] },
    ["qq_group"] = { icon = ResMgr.ui.service_qq_group, text = CHS[2100129] },
    ["wx"] = { icon = ResMgr.ui.service_wx, text = CHS[2100130] },
}

-- 默认雷霆的联系方式
local LT_SERVICE_INFOS = {
    {
        key = "tel",
        value = "0592-3011618",
    },
    {
        key = "wx",
        value = {"leitingkefu"},
    },
}

local PNG_HEAD = "\137\80\78\71"
local function checkFileValidity(filePath)
    if not gf:isFileExist(filePath) then return false end
    local f = io.open(filePath, "rb")
    local ext = gf:getFileExt(filePath)
    local len = f:seek("set")
    local headCode = f:read(4)
    f:close()
    if string.isNilOrEmpty(headCode) then
        -- 没有读到内容
        return false
    elseif "png" == ext then
        return headCode == PNG_HEAD
    end

    return false
end

function LoginForbidSimulatorDlg:init(data)
    self:setFullScreen()

    self:bindListener("ConfrimButton", self.onConfirmButton)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:bindListener("SendNoteTouchPanel", self.onSendReport)

    self:bindListener("NextButton", self.onNextButton)
    self:bindListener("LastButton", self.onLastButton)

    local listView = self:getControl("ContentListView")
    local panel = self:getControl("ContentPanel")
    panel:retain()
    panel:removeFromParent()
    listView:pushBackCustomItem(panel)
    panel:release()
    listView:doLayout()
    listView:addScrollViewEventListener(function(sender, eventType) self:updateSlider(sender, eventType) end)
    self:onLastButton()

    local endTime = data.ti
    local curTime = gf:getServerTime()

    local channelName = self:getChannelName()
    local picName, cfgName
    if channelName then
        picName = string.format("%s_install.png", channelName)
        cfgName = string.format("%s_install.lua", channelName)
    else
        picName = "install.png"
        cfgName = "install.lua"
    end

    local path, showImage
    path = cc.FileUtils:getInstance():getWritablePath() .. "patch/" .. cfgName
    if cc.FileUtils:getInstance():isFileExist(path) then
        -- 存在配置文件, 图片路径从文件获取
        local cfg = dofile(path)
        repeat
            if not cfg or not cfg.url or not cfg.checksum then break end    -- 没有有效的配置
            -- 存在配置，先检查本地是否存在图片文件
            path = cc.FileUtils:getInstance():getWritablePath() .. "patch/" .. picName
            if cc.FileUtils:getInstance():isFileExist(path) then
                local file = io.open(path, "rb")
                if not file then break end
                local fileData = file:read("*a")
                file:close()

                local md5 = require('core/md5')
                local checksum = md5.sumhexa(fileData)
                if checksum == cfg.checksum then break end
            end

            -- 文件不存在或md5校验失败，重新下载
            self.httpFile = HttpFile:create()
            if not self.httpFile then break end
            self.httpFile:retain()

            -- 回调请求
            local function _callback(state, value)
                if not self.httpFile then return end

                if 0 == state then
                    -- 下载完成
                    if checkFileValidity(path) then
                        self:setImage("Image", path, "IconPanel")
                    else
                        gf:ShowSmallTips(CHS[2200076])
                    end
                    self.httpFile:release()
                    self.httpFile = nil
                elseif 2 == state then
                    -- 下载失败
                    gf:ShowSmallTips(CHS[2200076])

                    self.httpFile:release()
                    self.httpFile = nil
                end
            end

            self.httpFile:setDelegate(_callback)
            self.httpFile:downloadFile(cfg.url, path)
            showImage = true
        until true

        if not path then
            path = cc.FileUtils:getInstance():getWritablePath() .. "patch/" .. picName
        end
    else
        path = cc.FileUtils:getInstance():getWritablePath() .. "patch/" .. picName
    end

    local tip
    local isFileExist = cc.FileUtils:getInstance():isFileExist(path)
    if isFileExist or showImage then
        self:setCtrlVisible("BeforePanel", true)
        self:setCtrlVisible("AfterPanel", false)
        if isFileExist and checkFileValidity(path) then
            self:setImage("Image", path, "IconPanel")
        end

        if curTime < endTime then
            tip = string.format(CHS[2100120], os.date("%Y", endTime), os.date("%m", endTime), os.date("%d", endTime), os.date("%H", endTime), os.date("%M", endTime))
        else
            tip = string.format(CHS[2100121], os.date("%Y", endTime), os.date("%m", endTime), os.date("%d", endTime), os.date("%H", endTime), os.date("%M", endTime))
        end
    else
        self:setCtrlVisible("BeforePanel", false)
        self:setCtrlVisible("AfterPanel", true)

        local defaultInfo = DistMgr:getDefaultInfo()
        local serviceInfos = defaultInfo.service_infos or LT_SERVICE_INFOS
        local count = 0
        for _, v in pairs(serviceInfos) do
            if v and v.key and TYPE2ICON[v.key] and v.value and #v.value > 0 then
                count = count + ('table' == type(v.value) and #v.value or 1)
            end
        end

        if count <= 0 then
            serviceInfos = LT_SERVICE_INFOS
            count = 2
        end

        -- 最多就四个
        count = math.min(count, 4)
        local panelName = string.format("AfterPanel_%d", count)
        local panel = self:getControl(panelName)
        local index = 1
        for _, v in pairs(serviceInfos) do
            if v and 'table' == type(v.value) then
                for i = 1, #v.value do
                    self:setImage(string.format("Image_%d", index), TYPE2ICON[v.key].icon, panel)
                    self:setLabelText(string.format("Label_%d", index), string.format(CHS[2100131], TYPE2ICON[v.key].text, v.value[i]), panel)
                    index = index + 1
                    if index > 4 then break end
                end
            elseif v and 'string' == type(v.value) then
                self:setImage(string.format("Image_%d", index), TYPE2ICON[v.key].icon, panel)
                self:setLabelText(string.format("Label_%d", index), string.format(CHS[2100131], TYPE2ICON[v.key].text, v.value), panel)
                index = index + 1
                if index > 4 then break end
            end
        end

        for k = 1, 4 do
            self:setCtrlVisible(string.format("AfterPanel_%d", k), k == count)
        end

        if curTime < endTime then
            tip = string.format(CHS[2100125], os.date("%Y", endTime), os.date("%m", endTime), os.date("%d", endTime), os.date("%H", endTime), os.date("%M", endTime))
        else
            tip = string.format(CHS[2100126], os.date("%Y", endTime), os.date("%m", endTime), os.date("%d", endTime), os.date("%H", endTime), os.date("%M", endTime))
        end
    end

--    local labelText = self:getControl("NoteLabel")
--    if labelText then
--        if not string.isNilOrEmpty(tip) then
--            labelText:setString(tip)
--        end
--    end
    self:setColorText(tip, "NotePanel_1", nil, nil, nil, COLOR3.WHITE, nil, true)

    self:setCtrlVisible("ConfirmButton", curTime >= endTime)
    self:setCtrlVisible("ContinueButton", curTime < endTime)

    DlgMgr:closeDlg("WaitDlg")
    Client.connectAgain = false
end

function LoginForbidSimulatorDlg:cleanup()
    if self.httpFile then
        self.httpFile:release()
        self.httpFile = nil
    end
end

function LoginForbidSimulatorDlg:getChannelName()
    local url = PLATFORM_CONFIG.MAIN_URL
    return gf:getChannelNameFromUrl(url)
end

function LoginForbidSimulatorDlg:onConfirmButton(sender, eventType)
    Client:clientDisconnectedServer({})
    self:onCloseButton()
end

function LoginForbidSimulatorDlg:onContinueButton(sender, eventType)
    Client:clientDisconnectedServer({})
    Client:setSimlatorLogin(true)
    DistMgr:connetAAA(Client:getWantLoginDistName(), true, Client.isNeedEnterGame)
    self:onCloseButton()
end

function LoginForbidSimulatorDlg:onSendReport(sender, eventType)
    gf:confirm(CHS[2200078], function()
        local hasSend = cc.UserDefault:getInstance():getBoolForKey("emu_error_send")
        if hasSend then
            gf:ShowSmallTips(CHS[2200079])
            return
        end

        gf:ftpUploadEx(DeviceMgr.emuCheckInfo)

        cc.UserDefault:getInstance():setBoolForKey("emu_error_send", true)

        gf:ShowSmallTips(CHS[2200080])
    end)
end

-- 更新滚动条
function LoginForbidSimulatorDlg:updateSlider(sender, eventType)
    if ccui.ScrollviewEventType.scrolling == eventType
        or ccui.ScrollviewEventType.scrollToTop == eventType
        or ccui.ScrollviewEventType.scrollToBottom == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)

        if persent > 90 and totalHeight > 0 then
            self:setCtrlVisible("SlipButton", false, "RulePanel")
        else
            self:setCtrlVisible("SlipButton", true, "RulePanel")
        end
    end
end

function LoginForbidSimulatorDlg:onNextButton(sender, eventType)
    self:setCtrlVisible("TipPanel", false)
    self:setCtrlVisible("RulePanel", true)

    self:setCtrlEnabled("LastButton", true)
    self:setCtrlEnabled("NextButton", false)
end

function LoginForbidSimulatorDlg:onLastButton(sender, eventType)
    self:setCtrlVisible("TipPanel", true)
    self:setCtrlVisible("RulePanel", false)

    self:setCtrlEnabled("LastButton", false)
    self:setCtrlEnabled("NextButton", true)
end

return LoginForbidSimulatorDlg