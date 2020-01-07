-- UnknownErrorDlg.lua
-- Created by huangzz/13/2017
-- 错误报告界面

local UnknownErrorDlg = Singleton("UnknownErrorDlg", Dialog)

function UnknownErrorDlg:init()
    self:setFullScreen()
    self:bindListener("SendButton", self.onSendButton)

    local bKPanel = self:getControl("BackImage")
    local InfoPanel = self:getControl("InfoPanel")

    -- 调整底部黑条的宽度及位置
    bKPanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE + 20, bKPanel:getContentSize().height)
end

function UnknownErrorDlg:setData(data, func)
    if not data.name or data.name == "" then
        data.name = CHS[5420132]
    end

    if not data.dist or data.dist == "" then
        data.dist = CHS[5420132]
    end

    if not data.id or data.id == "" then
        data.id = CHS[5420132]
    end

    if not data.time or data.time == "" then
        data.time = gf:getServerDate("%Y/%m/%d %H:%M:%S", gf:getServerTime())
    end

    self:setLabelText("NameLabel_2", gf:getRealName(data.name))
    self:setLabelText("GroupLabel_2", data.dist)
    self:setLabelText("TimeLabel_2", data.time)
    self:setLabelText("IDLabel_2", data.id)

    self.callFunc = func
end

function UnknownErrorDlg:onSendButton(sender, eventType)
    if self.callFunc then
        self.callFunc()
    end

    self:close()
end

return UnknownErrorDlg
