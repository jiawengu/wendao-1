-- FriendBoxDlg.lua
-- Created by liuhb Feb/12/2015
-- 好友界面

local FriendBoxDlg = Singleton("FriendBoxDlg", Dialog)

function FriendBoxDlg:init()
    self:bindListener("KeyboardButton", self.onKeyboardButton)
    self:bindListener("SpeakButton", self.onSpeakButton)
    self:bindListener("VoiceButton", self.onVoiceButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("KeyboardButton_1", self.onKeyboardButton_1)
    self:bindListener("LinkButton", self.onLinkButton)
    self:bindListener("KeyboardButton_2", self.onKeyboardButton_2)
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListViewListener("MessageListView", self.onSelectMessageListView)
end

function FriendBoxDlg:onKeyboardButton(sender, eventType)
end

function FriendBoxDlg:onSpeakButton(sender, eventType)
end

function FriendBoxDlg:onVoiceButton(sender, eventType)
end

function FriendBoxDlg:onExpressionButton(sender, eventType)
end

function FriendBoxDlg:onKeyboardButton_1(sender, eventType)
end

function FriendBoxDlg:onLinkButton(sender, eventType)
end

function FriendBoxDlg:onKeyboardButton_2(sender, eventType)
end

function FriendBoxDlg:onReturnButton(sender, eventType)
end

function FriendBoxDlg:onSelectMessageListView(sender, eventType)
end

return FriendBoxDlg
