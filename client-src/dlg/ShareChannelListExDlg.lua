-- ShareChannelListDlg.lua
-- Created by huangzz May/04/2018
-- 分享链接界面

local ShareChannelListExDlg = Singleton("ShareChannelListExDlg", Dialog)

-- 分享按钮对应的频道
local CHANNEL_MAP = {
    CHAT_CHANNEL.CURRENT,
    CHAT_CHANNEL.WORLD,
    CHAT_CHANNEL.PARTY,
    CHAT_CHANNEL.TEAM,
    CHAT_CHANNEL.FRIEND
}

function ShareChannelListExDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ShareChannelListDlg")
end

function ShareChannelListExDlg:init(para)
    for i = 1, 5 do
        local bth = self:getControl("ShareButton_" .. i)
        bth:setTag(CHANNEL_MAP[i])
        self:bindTouchEndEventListener(bth, self.onShareButton)
    end

    self.para = para
end

function ShareChannelListExDlg:setShareText(showInfo, sendInfo)
    self.showInfo = showInfo
    self.sendInfo = sendInfo
end

function ShareChannelListExDlg:isMeetCondition(chennel)
    if not self.para then
        return true
    end

    if self.para and string.match(self.para, "ShiJieBeiDlg") then
        -- 世界杯需要区分频道时间
        -- 早上做的时候，需要按照频道区分各个分享的限制间隔时间，下午的时候，又全部取消了！！！白做了早上！我也很无奈
        --[[
        if not self[self.para .. "time" .. chennel] then
            self[self.para .. "time" .. chennel] = 0
        end

        if self[self.para .. "time" .. chennel] ~= 0 and gfGetTickCount() - self[self.para .. "time" .. chennel] < 30 * 1000 then
            gf:ShowSmallTips(CHS[4300443])
            return false
        end

        self[self.para .. "time" .. chennel] = gfGetTickCount()
        --]]
        self:setLastOperTime(self.para .. "time",  gfGetTickCount())
    end

    return true

end

function ShareChannelListExDlg:showSmallTipsByPara()
    if not self.para then
        return
    end

    if string.match( self.para, "ShiJieBeiDlg" ) then
        gf:ShowSmallTips(CHS[4300450])
    end

    if string.match( self.para, "JiNianCeDlg" ) then
        gf:ShowSmallTips(CHS[2100157])
    end
end

function ShareChannelListExDlg:onShareButton(sender, eventType)
    if not self.showInfo or not self.sendInfo then
        return
    end

    if not self:isMeetCondition(sender:getTag()) then
        self:onCloseButton()
        return
    end

    -- local achieve = AchievementMgr:getAchieveInfoById(self.selectId)
    local tag = sender:getTag()
    -- local sendInfo = string.format("{\t%s=%s=%s}", achieve.name, CHS[4100818],  self.selectId)
    -- local showInfo = string.format(string.format("{\29%s\29}", achieve.name))

    DlgMgr:reorderDlgByName("ChannelDlg")
    if sender:getTag() == CHAT_CHANNEL.FRIEND then
        -- 分享到好友要先复制到粘贴板
        DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))

        self:showSmallTipsByPara()

        -- 真机上无法复制 \29 到输入框中，此处替换
        local copyInfo = string.gsub(self.showInfo, "\29", "")
        gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = self.showInfo, sendInfo = self.sendInfo})
    else
        -- 分享到频道输入框
        DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))

        DlgMgr:sendMsg("ChannelDlg", "setChannelInputChat", tag, "addCardInfo", self.sendInfo, self.showInfo)
    end

    self:onCloseButton()
end

function ShareChannelListExDlg:setPosWithDlg(dlg)
    local rect = self:getBoundingBoxInWorldSpace(dlg.root)
    if rect.x + rect.width * 0.5 < Const.WINSIZE.width * 0.5 then
        self:setPosition(cc.p(rect.x + rect.width + self.root:getContentSize().width * 0.5, rect.y + rect.height - self.root:getContentSize().height * 0.5))
    else
        self:setPosition(cc.p(rect.x - self.root:getContentSize().width * 0.5, rect.y + rect.height - self.root:getContentSize().height * 0.5))
    end

end

return ShareChannelListExDlg
