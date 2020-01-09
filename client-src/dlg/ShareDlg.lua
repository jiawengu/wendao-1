-- ShareDlg.lua
-- Created by liuhb Mar/1/2016
-- 分享界面

local ShareDlg = Singleton("ShareDlg", Dialog)

local OFFSET_X = 48
local INTERVAL_X = 30

local SHOW_COU = 3
local TOTAL_COU = 6

function ShareDlg:init(showCou)
    self:bindListener("WeiXinButton", self.onWeiXinButton)
    self:bindListener("WeiXinPengYouButton", self.onWeiXinPengYouButton)
    self:bindListener("BlogButton", self.onBlogButton)
    self:bindListener("QQButton", self.onQQButton)
    self:bindListener("QQKongJianButton", self.onQQKongJianButton)
    self:bindListener("WeiBoButton", self.onWeiBoButton)

    -- 计算宽度
    showCou = showCou or SHOW_COU
    
    if showCou < 3 then
        -- 前两个图标是微信、朋友圈，隐藏第三个图片个人空间
        -- 非截图的图片暂时不用分享到个人空间
        self:setCtrlVisible("BlogButton", false)
    end

    local panel = self:getControl("SharePanel")
    local contentSize = panel:getContentSize()
    local width = (contentSize.width - OFFSET_X * 2 - INTERVAL_X * (TOTAL_COU - 1)) / TOTAL_COU * showCou + OFFSET_X * 2 + INTERVAL_X * (showCou - 1)

    panel:setContentSize(width, contentSize.height)
    self:getControl("BackImage"):setPositionX(width / 2)

    -- 暂时屏蔽
    self:setCtrlVisible("QQButton", false)
    self:setCtrlVisible("QQKongJianButton", false)
    self:setCtrlVisible("WeiBoButton", false)
    
    -- 确保在要分享的悬浮框层级之上
    self.blank:setLocalZOrder(Const.ZORDER_SHARE)
end

function ShareDlg:setShareType(type)
    self.type = type
end

function ShareDlg:getShareType()
    return self.type or SHARE_TYPE_CONFIG.SHARE_PIC
end

function ShareDlg:setCurShareData(data)
    self.shareData = data
end

function ShareDlg:getCurShareData()
    return self.shareData
end

function ShareDlg:cleanup()
    self.shareData = nil
    self.type = nil
    self.callback = nil
    DlgMgr:closeDlg("ShareLineDlg")
end

function ShareDlg:setCapCallBack(callback)
    self.callback = callback
end

function ShareDlg:setStartCapToShare(sharePlat)
    local shareData = self.shareData
    if self.callback then
        self.callback(function()
            if sharePlat == SHARE_TYPE.ATMBLOG then
                BlogMgr:openBlog(nil, nil, function() 
                    BlogMgr:sendMsgToMyBlogCircleDlg("sharePic", shareData)
                end)
            else
                ShareMgr:shareToPlat(sharePlat, shareData)
            end
        end, sharePlat)

        -- 记录分享日志
        ShareMgr:recordShareAction(sharePlat, shareData.typeStr)
    else
        -- 没有截图回调，表示要分享的是已有的图片
        if sharePlat == SHARE_TYPE.ATMBLOG then
            BlogMgr:openBlog(nil, nil, function()
                BlogMgr:sendMsgToMyBlogCircleDlg("sharePic", shareData)
            end)
        else
            ShareMgr:shareToPlat(sharePlat, shareData)
        end

        if ShareMgr.shareActName == "movie_hancheng_fenxiang" then
            -- 记录分享日志
            ShareMgr:recordShareAction(sharePlat, SHARE_FLAG.HANCHENGHUDONG)
        end
    end

    self:onCloseButton()
end

function ShareDlg:onWeiXinButton(sender, eventType)
    if self:getShareType() == SHARE_TYPE_CONFIG.SHARE_PIC then
        self:setStartCapToShare(SHARE_TYPE.WECHAT)
    else
        ShareMgr:shareUrlToPlat(SHARE_TYPE.WECHAT, self.shareData.url, self.shareData.title, self.shareData.desc,
            self.shareData.thumbPath, self.shareData.needNotifyServer, self.shareData.shareFlag)
    end    
end

function ShareDlg:onWeiXinPengYouButton(sender, eventType)
    if self:getShareType() == SHARE_TYPE_CONFIG.SHARE_PIC then
        self:setStartCapToShare(SHARE_TYPE.WECHATMOMENTS)
    else
        ShareMgr:shareUrlToPlat(SHARE_TYPE.WECHATMOMENTS, self.shareData.url, self.shareData.title, self.shareData.desc,
            self.shareData.thumbPath, self.shareData.needNotifyServer, self.shareData.shareFlag)
    end    
end

function ShareDlg:onBlogButton(sender, eventType)
    self:setStartCapToShare(SHARE_TYPE.ATMBLOG)
end

function ShareDlg:onQQButton(sender, eventType)
    self:setStartCapToShare(SHARE_TYPE.QQ)
end

function ShareDlg:onQQKongJianButton(sender, eventType)
    self:setStartCapToShare(SHARE_TYPE.QZONE)
end

function ShareDlg:onWeiBoButton(sender, eventType)
    self:setStartCapToShare(SHARE_TYPE.SINAWEIBO)
end

return ShareDlg
