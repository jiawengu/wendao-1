-- GMDebugTipsDlg.lua

local GMDebugTipsDlg = Singleton("GMDebugTipsDlg", Dialog)

local function afterCaptured(succeed, outputFile)
    if succeed then
        gf:ShowSmallTips(CHS[3002704])
    else
        gf:ShowSmallTips(CHS[3002705])
    end
end

function GMDebugTipsDlg:init()
    self:bindListener("CaptureButton", self.onCaptureButton)
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function GMDebugTipsDlg:setTitle(title)
    self:setLabelText('TitleLabel_1', title)
    self:setLabelText('TitleLabel_2', title)
end

function GMDebugTipsDlg:onCaptureButton(sender, eventType)
    local fileName = os.date("%Y%m%d%H%M%S", os.time())..".png"
    cc.utils.captureScreen(self, afterCaptured, fileName)
end

function GMDebugTipsDlg:setErrStr(errStr)
    local scrollView = self:getControl("ScrollView")
    scrollView:removeAllChildren()
    local panel = ccui.Layout:create()
    panel:setContentSize(scrollView:getContentSize())
    scrollView:addChild(panel)
    local panelHeight = self:setColorText(errStr, panel, nil, nil, nil, nil, 19)
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, panelHeight))
    local px, py = panel:getPosition()
    panel:setPosition(px, math.max(0, scrollView:getContentSize().height - panelHeight))

    scrollView.errStr = errStr
end

function GMDebugTipsDlg:appendErrStr(errStr)
    local str = self:getControl("ScrollView").errStr or ""
    self:setErrStr(str .. errStr)
end

function GMDebugTipsDlg:insertErrStr(errStr)
    local str = self:getControl("ScrollView").errStr or ""
    self:setErrStr(errStr .. "\n" .. str)
end

function GMDebugTipsDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_FETCH_MINFO == data.notify then
        local info = gfDecrypt(data.para, string.rep("7", 7))
        if not string.match(info, "^[-0-9][0-9]") then
            info = "Info from server is invalid"
        end

        self:insertErrStr(info)
    end
end

return GMDebugTipsDlg
