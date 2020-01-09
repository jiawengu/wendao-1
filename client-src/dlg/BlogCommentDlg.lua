-- BlogCommentDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间 评论输入

local BlogCommentDlg = Singleton("BlogCommentDlg", Dialog)

local MSG_LIMIT = 50 * 2

function BlogCommentDlg:init()
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("DelButton", self.onDelButton)
    self:setCtrlVisible("DelButton", false)

    self.newNameEdit = self:createEditBox("TextPanel", nil, nil, function(sender, type)
        if type == "ended" then
            self.newNameEdit:setText("")
            self:setCtrlVisible("ContentLabel", true)
        elseif type == "began" then
            local msg = self:getLabelText("ContentLabel")
            self.newNameEdit:setText(msg)
            self:setCtrlVisible("ContentLabel", false)
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelButton", false)
                self:setCtrlVisible("NoneLabel", true)
            else
                self:setCtrlVisible("NoneLabel", false)
                self:setCtrlVisible("DelButton", true)
            end

            self:setLabelText("ContentLabel", newName)
        end
    end)

    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setFont(CHS[3003597], 19)
    self.newNameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.newNameEdit:setText("")
    self.data = nil
end

function BlogCommentDlg:setData(data)
    self.data = data

    if data.charGid ~= Me:queryBasic("gid") then
        self:setLabelText("NoneLabel", string.format(CHS[4100854], data.name))
    end
end

-- 表情界面关闭时
function BlogCommentDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("BlogCommentDlg")
end

-- 插入表情
function BlogCommentDlg:addExpression(expression)

    local content = self:getLabelText("ContentLabel")
    if gf:getTextLength(content .. expression) > MSG_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. expression

    if not self:getCtrlVisible("ContentLabel") then
        -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
        self.newNameEdit:setText(content)
    end

    self:setLabelText("ContentLabel", content)
    self:setCtrlVisible("NoneLabel", false)
    self:setCtrlVisible("DelButton", true)
end

-- 切换输入
function BlogCommentDlg:swichWordInput()
    if not self.newNameEdit then return end

    self.newNameEdit:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end

-- 增加空格
function BlogCommentDlg:addSpace()
    local content = self:getLabelText("ContentLabel")
    if gf:getTextLength(content .. " ") > MSG_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. " "

    if not self:getCtrlVisible("ContentLabel") then
        -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
        self.newNameEdit:setText(content)
    end

    self:setLabelText("ContentLabel", content)
    self:setCtrlVisible("NoneLabel", false)
    self:setCtrlVisible("DelButton", true)
end

-- 删除字符
function BlogCommentDlg:deleteWord()
    local text = self:getLabelText("ContentLabel")
    local len  = string.len(text)
    local deletNum = 0

    if len > 0 then
        if string.byte(text, len) < 128 then       -- 一个字符
            deletNum = 1
        elseif string.byte(text, len - 1) >= 128 and string.byte(text, len - 2) >= 224 then    -- 三个字符
            deletNum = 3
        elseif string.byte(text, len - 1) >= 192 then     -- 两个个字符
            deletNum = 2
        end

        local newtext = string.sub(text, 0, len - deletNum)
        if not self:getCtrlVisible("ContentLabel") then
            -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
            self.newNameEdit:setText(newtext)
        end

        self:setLabelText("ContentLabel", newtext)
        self:setCtrlVisible("NoneLabel", false)
        self:setCtrlVisible("DelButton", true)

        if len - deletNum <= 0 then
            self:setCtrlVisible("NoneLabel", true)
            self:setCtrlVisible("DelButton", false)
        end
    else
        self:setCtrlVisible("DelButton", false)
    end
end

-- 发送消息
function BlogCommentDlg:sendMessage(content)
    DlgMgr:closeDlg("LinkAndExpressionDlg")
    self:onSendButton()
end

function BlogCommentDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "blog")

    -- 界面上推
    local mainPanel = self:getControl("MainPanel")
    local heigth = math.max(0, dlg:getMainBodyHeight() - mainPanel:getPositionY())
    DlgMgr:upDlg("BlogCommentDlg", heigth)
end


function BlogCommentDlg:onDelButton(sender, eventType)
    self:setLabelText("ContentLabel", "")
    self:setCtrlVisible("NoneLabel", true)
    self:setCtrlVisible("DelButton", false)
end

function BlogCommentDlg:onSendButton(sender, eventType)

    -- 实名认证（防沉迷）
    if Me:getAdultStatus() == 2 then
        gf:ShowSmallTips(CHS[4100860])
        return
    end

    -- 敏感字
    local content = self:getLabelText("ContentLabel")
    local nameText, haveBadName = gf:filtText(content, nil, true)
    if haveBadName then
        gf:confirm(CHS[4100770], function ()
            self:setLabelText("ContentLabel", nameText)
        end, nil, nil, nil, nil, nil, true)
        return
    end

    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[5400265])
        return
    end


    if DlgMgr:getDlgByName("TradingSpotDiscussDlg") then
        TradingSpotMgr:publishBBSComment(self.data.uid, self.data.sid, self.data.reply_cid, self.data.charGid, self.data.reply_dist, content, self.data.isExpand, self.data.status_dist)
    else
        BlogMgr:publishComment(self.data.uid, self.data.sid, self.data.reply_cid, self.data.charGid, self.data.reply_dist, content, self.data.isExpand, self.data.status_dist)
    end


    self:onCloseButton()
end

return BlogCommentDlg
