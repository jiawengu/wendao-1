-- GMConfirmDlg.lua
-- Created by songcw Feb/23/2016
-- GM输入对话框

local GMConfirmDlg = Singleton("GMConfirmDlg", Dialog)

function GMConfirmDlg:init()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:align(ccui.RelativeAlign.centerInParent)
    self.root:requestDoLayout()
    
    -- 事件监听
    self:bindTouchEndEventListener(self.root, self.onCloseButton)

    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
end

function GMConfirmDlg:setSearchType(searchType, userInfo)
    self.userInfo = userInfo
    local tips = CHS[3002700]
    if searchType == "name" then
        tips = CHS[3002700]
    elseif searchType == "gid" then
        tips = CHS[3002701]
    elseif searchType == "account" then
        tips = CHS[3002702]        
    elseif searchType == "kickOff" then
        local tips2 = string.format(CHS[3002703], userInfo.name)   
        self:setDescript(tips2, self:getControl("NotePanel"), COLOR3.WHITE)
        tips = ""
        self:setCtrlVisible("InputTextField", false)
    end
    self.searchType = searchType
    self:setLabelText("Label", tips, "InputPanel")
end

function GMConfirmDlg:setDescript(descript, panel, defaultColor)
    --   local panel = self:getControl("DescPanel")
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b) end
    textCtrl:setFontSize(23)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()
 --   ccui.TextField
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,(panel:getContentSize().height + textH) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    return textH
end

function GMConfirmDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function GMConfirmDlg:onConfirmButton(sender, eventType)
    local user = self:getInputText("InputTextField")
    if self.searchType == "account" then
        GMMgr:cmdQueryByAccount(user, "list")
    elseif self.searchType == "kickOff" then
        GMMgr:cmdKickOffPlayer(self.userInfo.name)
    else
        GMMgr:cmdQueryByPlayer(user, self.searchType)
    end
    
    self:onCloseButton()
end

return GMConfirmDlg
