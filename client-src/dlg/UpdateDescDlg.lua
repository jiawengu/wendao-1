-- UpdateDescDlg.lua
-- Created by zhengjh Sep/2015/17
-- 更新内容

local CommonDescDlg = require("dlg/CommonDescDlg")
local UpdateDescDlg = Singleton("UpdateDescDlg", CommonDescDlg)
local RadioGroup = require("ctrl/RadioGroup")

local noLogin = false

function UpdateDescDlg:init()
    self.listView = self:getControl("UpdateListView")
    DlgMgr:setVisible("UserLoginDlg", false)


    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"UpdateDescDlgCheckBox","OffLineActiveDlgCheckBox"}, self.onCheckBox)

    if self.blank.colorLayer then
        self.blank:removeChild(self.blank.colorLayer)
    end
end

function UpdateDescDlg:setDescInfo(list)
    self.tabDataList = list
    if #self.tabDataList <= 1 then -- 如果只有一个数据隐藏一个标签页
        local updateCheckBox = self:getControl("UpdateDescDlgCheckBox")
        local activeCheckBox = self:getControl("OffLineActiveDlgCheckBox")
        if list[1].name == "update" then
            -- 显示公告标签页
            activeCheckBox:setVisible(false)
            self.radioGroup:selectRadio(1)
        else
            -- 显示活动标签页
            updateCheckBox:setVisible(false)
            activeCheckBox:setPosition(updateCheckBox:getPosition())
            self.radioGroup:selectRadio(2)
        end
    else
        self.radioGroup:selectRadio(1)
    end
end

function UpdateDescDlg:onCheckBox(sender, eventType)
    local name = sender:getName()
    if name == "UpdateDescDlgCheckBox" then
        self:initContent(self:getDataByKey("update").desc, "UpdateListView")
        self:setLabelText("TitleLabel_1", CHS[6200001])
        self:setLabelText("TitleLabel_2", CHS[6200001])
        self:setCtrlVisible("UpdateListView", true)
        self:setCtrlVisible("ActiveListView", false)
    elseif name == "OffLineActiveDlgCheckBox" then
        self:initContent(self:getDataByKey("active").desc, "ActiveListView")
        self:setLabelText("TitleLabel_1", CHS[6200000])
        self:setLabelText("TitleLabel_2", CHS[6200000])
        self:setCtrlVisible("UpdateListView", false)
        self:setCtrlVisible("ActiveListView", true)
        NoticeMgr:setIsNeddShowActivityRedDot(false)
    end
end

function UpdateDescDlg:getDataByKey(key)
    local list = {}
    for i = 1, #self.tabDataList do
        if self.tabDataList[i].name == key then
            list = self.tabDataList[i]
            break
        end
    end

    return list
end

-- 获取控件
function UpdateDescDlg:getControl(name, type, root)
    root = root or self.root
    local widget = ccui.Helper:seekWidgetByName(root, name)
    return widget
end


-- 控件绑定事件
function UpdateDescDlg:bindListener(name, func, root)
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
function UpdateDescDlg:bindTouchEndEventListener(ctrl, func, data)
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


function UpdateDescDlg:onCloseButton()
    if not NoticeMgr:showLoginAnnouncement(noLogin) then
        if not noLogin then
            DlgMgr:setVisible("UserLoginDlg", true)
            LeitingSdkMgr:login()
        else
            if noLogin == 1 then
                DlgMgr:setVisible("UserLoginDlg", true)
            else
                DlgMgr:openDlg("SystemConfigDlg")
            end
        end
    end

    DlgMgr:closeDlg(self.name)
end

-- 设置是否需要打开登录过程
function UpdateDescDlg:setNoLogin(flag)
    noLogin = flag
end

function UpdateDescDlg:cleanup()
    noLogin = false
end

return UpdateDescDlg
