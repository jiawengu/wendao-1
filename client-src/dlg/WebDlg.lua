-- WebDlg.lua
-- Created by lixh Jan/11/2018
-- 网页界面(游戏内打开url)

local WebDlg = Singleton("WebDlg", Dialog)

-- 页面加载倒计时最大时间
local LOAD_MAX_TIME = 10

-- 网页标记
local WEBPAGE_TAG = 999

function WebDlg:init(data)
    self.curUrl = data.url
    self:setCtrlVisible("NoticePanel", false)
    self:setLabelText("InfoLabel1", CHS[7150035], "NoticePanel")

    self.webView = ccexp.WebView:create()
    local webPanel = self:getControl("WebPanel")
    local panelSize = webPanel:getContentSize()
    self.webView:setScalesPageToFit(true)
    self.webView:setContentSize(panelSize)
    self.webView:setAnchorPoint(0, 0)
    self.webView:setTag(WEBPAGE_TAG)
    webPanel:addChild(self.webView)
    self.webView:setVisible(false)

    self.webView:setOnDidFailLoading(function()
        if not DlgMgr:isDlgOpened(self.name) then
            return
        end

        self:clearSchedule()
        DlgMgr:closeDlg("WaitDlg")
        self:setCtrlVisible("NoticePanel", true)

        local webPanel = self:getControl("WebPanel")
        webPanel:removeChildByTag(WEBPAGE_TAG)
        self.webView = nil
    end)

    self.webView:setOnDidFinishLoading(function(sender, url)
        if not DlgMgr:isDlgOpened(self.name) then
            return
        end

        self:clearSchedule()
        DlgMgr:closeDlg("WaitDlg")
        self:setCtrlVisible("NoticePanel", false)

        self.webView:setVisible(self:isVisible())
        self.curUrl = url
    end)

    self.webView:loadURL(self.curUrl)
    local startTime = LOAD_MAX_TIME
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            if startTime > 0 then
                -- 显示倒计时
                DlgMgr:openDlg("WaitDlg")
                startTime = startTime - 1
            else
                -- 加载失败
                self:clearSchedule()
                local webPanel = self:getControl("WebPanel")
                webPanel:removeChildByTag(WEBPAGE_TAG)
                self.webView = nil

                DlgMgr:closeDlg("WaitDlg")
                self:setCtrlVisible("NoticePanel", true)
            end
        end, 1)
    end

    self:setVisible(true)
    self.webView:setVisible(false)
    self:MSG_ENTER_ROOM()

    self:hookMsg("MSG_ENTER_ROOM")
end

function WebDlg:getCfgFileName()
    return ResMgr:getDlgCfg("CommunityDlg")
end

-- 隐藏或显示界面
function WebDlg:setVisible(flag, ignoreLoading)
    if flag and not DlgMgr:canShowWebDlg(ignoreLoading, self.name) then
        flag = false
    end

    Dialog.setVisible(self, flag)

    if self.webView then
        local noticePanel = self:getControl("NoticePanel")
        self.webView:setVisible(flag and not noticePanel:isVisible())
    end
end

-- 停止倒计时
function WebDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end
end

function WebDlg:cleanup()
    self:clearSchedule()
    self.webView = nil
end

function WebDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
end

function WebDlg:MSG_ENTER_ROOM()
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

return WebDlg
