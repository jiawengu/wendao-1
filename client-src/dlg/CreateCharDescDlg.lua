-- CreateCharDescDlg.lua
-- Created by zhengjh Sep/2015/17
-- 更新内容

local CommonDescDlg = require("dlg/CommonDescDlg")
local CreateCharDescDlg = Singleton("CreateCharDescDlg", CommonDescDlg)

local noLogin = false

local FONTSIZE_TITLE = 21 -- 一级文本、标题字体大小
local FONTSIZE_TEXT2 = 19 -- 二级文本字体大小

function CreateCharDescDlg:getCfgFileName()
    --return ResMgr:getDlgCfg("UpdateDescDlg")
    -- 吕寅给了新界面.......
    return ResMgr:getDlgCfg("LoginNewDistActiveDlg")
end

function CreateCharDescDlg:init()
    self.listView = self:getControl("UpdateListView")
    DlgMgr:setVisible("UserLoginDlg", false)
    self:setCtrlVisible("ActiveListView", false)

    self:setLabelText("TitleLabel_1", CHS[4400010])
    self:setLabelText("TitleLabel_2", CHS[4400010])

    self:setCtrlVisible("SwitchPanel_0", false)
    if self.blank.colorLayer then
        self.blank:removeChild(self.blank.colorLayer)
    end
end

function CreateCharDescDlg:onCloseButton()
    if not DlgMgr:isDlgOpened("LoginChangeDistDlg") then
        DlgMgr:setVisible("UserLoginDlg", true)
       -- LeitingSdkMgr:login()
    else
        -- WDSY-36728 预充值与预创角界面可能同时打开，通过预充值界面切换到预创角在关闭界面，需要增加显示 LoginChangeDistDlg
        DlgMgr:setVisible("LoginChangeDistDlg", true)
    end

    DlgMgr:closeDlg("WaitDlg")
    DlgMgr:closeDlg("CreateCharDlg")
    DlgMgr:closeDlg(self.name)
end

function CommonDescDlg:getListView()
    return "UpdateListView"
end

-- 获取控件
function CreateCharDescDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end


-- 控件绑定事件
function CreateCharDescDlg:bindListener(name, func, root)
    if nil == func then
        Log:W("Dialog:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name,nil,root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("Dialog:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

-- 为指定的控件对象绑定 TouchEnd 事件
function CreateCharDescDlg:bindTouchEndEventListener(ctrl, func, data)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType, data)
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 设置是否需要打开登录过程
function CreateCharDescDlg:setNoLogin(flag)
    noLogin = flag
end

function CreateCharDescDlg:cleanup()
    noLogin = false
end

return CreateCharDescDlg
