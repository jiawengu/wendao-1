-- ShareChannelListDlg.lua
-- Created by huangzz May/04/2018
-- 分享链接界面

local ShareChannelListDlg = Singleton("ShareChannelListDlg", Dialog)

-- 分享按钮对应的频道
local CHANNEL_MAP = {
    CHAT_CHANNEL.CURRENT,
    CHAT_CHANNEL.WORLD,
    CHAT_CHANNEL.PARTY,
    CHAT_CHANNEL.TEAM,
    CHAT_CHANNEL.FRIEND
}

function ShareChannelListDlg:init()
    for i = 1, 5 do
        local bth = self:getControl("ShareButton_" .. i)
        bth:setTag(CHANNEL_MAP[i])
        self:bindTouchEndEventListener(bth, self.onShareButton)
    end
end

function ShareChannelListDlg:setShareText(showInfo, sendInfo, type)
    self.showInfo = showInfo
    self.sendInfo = sendInfo
    self.type = type
end

function ShareChannelListDlg:onShareButton(sender, eventType)
    if not self.showInfo or not self.sendInfo then
        return
    end

    local tag = sender:getTag()
    DlgMgr:reorderDlgByName("ChannelDlg")
    if sender:getTag() == CHAT_CHANNEL.FRIEND then
        -- 分享到好友要先复制到粘贴板
        DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))

        if self.type == "shengsizhuang" then
            gf:ShowSmallTips(CHS[5400599])
        end
        
        -- 真机上无法复制 \29 到输入框中，此处替换 
        local copyInfo = string.gsub(self.showInfo, "\29", "")
        gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = self.showInfo, sendInfo = self.sendInfo})
        return
    else
        -- 分享到频道输入框
        DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))
    
        DlgMgr:sendMsg("ChannelDlg", "setChannelInputChat", tag, "addCardInfo", self.sendInfo, self.showInfo) 
    end

    self:onCloseButton()
end

return ShareChannelListDlg
