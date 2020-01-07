-- AddFriendVerifyDlg.lua
-- Created by liuhb Feb/28/2015
-- 发送好友验证消息界面

local AddFriendVerifyDlg = Singleton("AddFriendVerifyDlg", Dialog)

local lenMax = 16

function AddFriendVerifyDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("DelAllButton", self.onDelAllButton)

    self:bindEditField("TextField", lenMax, "DelAllButton")
end


function AddFriendVerifyDlg:bindEditField(ctrlName, lenLimit, clenButtonName)
    local textCtrl = self:getControl(ctrlName, nil)
    self:setCtrlVisible(clenButtonName, false)
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible(clenButtonName, true)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空,如果将来需要有清空输入按钮
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible(clenButtonName, false)
            end
        end
    end)
end

function AddFriendVerifyDlg:onConfirmButton(sender, eventType)
    local text = self:getInputText("TextField")

    if text ~= "" then
        local text, haveFit = gf:filtText(text)
        if haveFit then
            return
        end
    end

    FriendMgr:sendFriendCheck(self.charName, self.gid, text)

    DlgMgr:closeDlg("AddFriendVerifyDlg")
end

function AddFriendVerifyDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg("AddFriendVerifyDlg")
end

function AddFriendVerifyDlg:onDelAllButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("DelAllButton", false)
end

function AddFriendVerifyDlg:setInfo(info)
    self.charName = info.name
    self.gid = info.gid
    local titleStr = string.format(CHS[5000071], info.name, info.id)
    local panelCtrl = self:getControl("AddNamePanel")
    panelCtrl:removeAllChildren()
    local size = panelCtrl:getContentSize()
    local titleCtrl = CGAColorTextList:create(true)
    titleCtrl:setFontSize(20)
    titleCtrl:setString(titleStr)
    titleCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    titleCtrl:updateNow()
    local textW, textH = titleCtrl:getRealSize()
    local layer = tolua.cast(titleCtrl, "cc.LayerColor")
    layer:setPosition(size.width/2, size.height / 2)
    layer:setAnchorPoint(0.5, 0.5)

    panelCtrl:addChild(layer)
end

return AddFriendVerifyDlg
