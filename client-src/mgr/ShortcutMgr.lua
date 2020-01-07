-- ShortcutMgr.lua
-- Created by sujl Mar/9/2016
-- 负责游戏自动登录处理

ShortcutMgr = Singleton()

-- 操作
-- 0：无  1:查看摆摊 2:好友聊天 3:活动列表
local curOper = 0

-- 是否延时处理
-- 如果从后台返回前天需要重新登录的话
-- 快捷操作需要登录完成后再处理
ShortcutMgr.delayOper = false

-- 设置快捷操作
function ShortcutMgr:setOper(oper)
    Log:D(string.format("ShortcutMgr:setOper:%d", oper))
    curOper = oper

    if 3 ~= GameMgr.clientStatus and 0 ~= curOper and not ShortcutMgr.delayOper then
        ShortcutMgr:doWhenEnterForeground()
    end
end

-- 游戏登录成功
function ShortcutMgr:enterGame()
    if 0 == curOper then
        return
    end

    local dlg = DlgMgr:getDlgByName("UserLoginDlg");
    if dlg then
        dlg:enterGame()
    else
        self:clearState()
    end
end

-- 清除状态
function ShortcutMgr:clearState()
    curOper = 0
    ShortcutMgr.delayOper = false
end

-- 后处理
function ShortcutMgr:postProcess()
    if 0 == curOper then
        return
    end

    if 1 == curOper then        -- 查看摆摊
        self:viewMarketSell()
    elseif 2 == curOper then    -- 好友聊天
        self:viewFriend()
    elseif 3 == curOper then    -- 活动列表
        self:viewActivity()    
    end

    self:clearState()
end

-- 游戏进入前台
function ShortcutMgr:doWhenEnterForeground()
    if 0 == curOper then
        -- 没有设置任何快捷操作
        return
    end

    local gameState = GameMgr:getGameState() or GAME_RUNTIME_STATE.PRE_LOGIN
    if GAME_RUNTIME_STATE.MAIN_GAME == gameState then
        -- 已经在游戏中
        if not GuideMgr:isRunning() then
            self:postProcess()
        else
            self:clearState()
        end
    elseif GAME_RUNTIME_STATE.PRE_LOGIN == gameState then
        -- 还未进入游戏
        if LeitingSdkMgr:isLogined() then
            self:enterGame()
        else
            self:clearState()
        end
    end
end

-- 进入世界
function ShortcutMgr:doWhenEnterWorld()
    self:postProcess()
end

-- 查看摆摊
function ShortcutMgr:viewMarketSell()
    local dlgName = "MarketTabDlg"
    local dlgs = { "MarketBuyDlg", "MarketSellDlg", "MarketPublicityDlg", "MarketAuctionDlg" }
    local dlg = DlgMgr:getDlgByName(dlgName)

    if dlg and dlg:isVisible() then
        for i = 1, #dlgs do
            local subDlg = DlgMgr:getDlgByName(dlgs[i])
            if subDlg and subDlg:isVisible() then
                subDlg:reopen()
                break
            end
        end
        dlg:reopen()
    else
        DlgMgr:openDlg("MarketBuyDlg")
    end
end

-- 好友聊天
function ShortcutMgr:viewFriend()
    FriendMgr:openFriendDlg()

    local dlg = DlgMgr:getDlgByName("FriendDlg")
    if dlg and dlg:isVisible() then
        dlg:reopen()
    end
end

-- 活动界面
function ShortcutMgr:viewActivity()
    if not GuideMgr:isIconExist(18) then
        gf:ShowSmallTips(CHS[3004312])
        return
    end
    
    local dlg = DlgMgr:getDlgByName("ActivitiesDlg")

    if dlg and dlg:isVisible() then
        dlg:reopen()
    else
        DlgMgr:openDlgWithParam('ActivitiesDlg')
    end
end

return ShortcutMgr