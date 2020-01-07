require "Cocos2d"
require "Cocos2dConstants"

local LoginScene = class("LoginScene", Scene)

function LoginScene:init()
    if type(gfResetTickCount) == "function" and not DistMgr:getIsSwichServer() then
        -- 换线不重置
        Client:resetTickCount()
    end

    local winsize = cc.Director:getInstance():getWinSize()

    self.loginBack = nil

    DlgMgr:openDlg("UserLoginDlg")
    self:checkAgreement()

    GameMgr.isEnterGameByLoginScene = true
    GameMgr:keepAutoWalkWhenLoginDone()

    -- 清除aaa请求角色信息的缓存
    DistMgr:clearDistRoleInfo()

    -- 播放登录音乐
    SoundMgr:playMusic("loginMusic")

    if ATM_IS_DEBUG_VER and gf:isWindows() then
        -- 检测是否有同名 NPC
        MapMgr:checkSameNameInMaps()

        -- 检测活动配表中是否有同名活动
        ActivityMgr:checkSameNameActivity()
    end
end

function LoginScene:onNodeEnter()
    local LoginBack = require("dlg/LoginBack2019Dlg")
    local backNode = LoginBack.new({doAction = true})
    self:addChild(backNode)
    backNode:setLocalZOrder(-1)
    self.loginBack = backNode
end

-- 检查用户协议
function LoginScene:checkAgreement()
    NoticeMgr:setAgreementVersion()

    local userDefault =  cc.UserDefault:getInstance()
    local isshowUpdateDesc = userDefault:getStringForKey("showUpdateDesc", "")
    if NoticeMgr:isNeedShowAgreement() then
        self:showUserAgreement()
    else
        if NoticeMgr:isShowUpdate() then
            -- 已经弹过对话框
        elseif NoticeMgr:showLoginAnnouncement() then
            -- 已经弹过渠道公告界面
        elseif not Client.dontDoLogin then
            if not LeitingSdkMgr:isLogined() then
                -- 未登录过，此时要执行 login 逻辑
                LeitingSdkMgr:login()
            end
        end
    end

end

-- 用户协议
function LoginScene:showUserAgreement()
  --[[  local runScene =  cc.Director:getInstance():getRunningScene()
    local UserAgreementDlg = require('dlg/UserAgreementDlg')
    local userAgreementDlg = UserAgreementDlg.create()
    self:addChild(userAgreementDlg)]]
    DlgMgr:openDlg("UserAgreementDlg")
end

function LoginScene:moveLoginBack(x, y)
    if not self.loginBack then return end

    self.loginBack:move(x, y)
end

return LoginScene
