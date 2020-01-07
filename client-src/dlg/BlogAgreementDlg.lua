-- BlogAgreementDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间 - 协议界面

local BlogAgreementDlg = Singleton("BlogAgreementDlg", Dialog)

function BlogAgreementDlg:init(param)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    
    self.parentDlg = param
end

function BlogAgreementDlg:onRefuseButton(sender, eventType)
    self:onCloseButton()
end

function BlogAgreementDlg:onAgreeButton(sender, eventType)
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setIntegerForKey("BlogAgreementDlg", 1)
    BlogMgr:agreement()

    DlgMgr:sendMsg(self.parentDlg, "onWriteButton")
    self:onCloseButton()
end

return BlogAgreementDlg
