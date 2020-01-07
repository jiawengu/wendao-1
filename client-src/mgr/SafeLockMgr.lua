-- GMMgr.lua
-- Created by songcw Feb/24/2016
-- 安全锁管理器

SafeLockMgr = Singleton()

local CONTINUE_TYPE = {
    FROM_DLG    = 1,
    FROM_MODULE = 2,
}

-- 安全锁绑定输入框，特殊处理了“*”与最后一个字符(设置、验证、修改界面)
function SafeLockMgr:bindInputToSafeLock(dlgName, panelName, numLimit)
    local dlg = DlgMgr:getDlgByName(dlgName)
    if not dlg then
        return
    end
    
    -- 输入框上移高度
    local dlgUpHeight = dlg:getControl("BKPanel"):getContentSize().height / 2
    
    local panel = dlg:getControl(panelName)
    local textCtrl = dlg:getControl("TextField", nil, panel)
    textCtrl:setOpacity(0)
    dlg:bindEditFieldForSafe(panelName, numLimit, "CleanFieldButton", nil, function (dlg, sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
            -- 插入或删除字符
            local textCtrl = dlg:getControl("TextField", nil, panel)
            local str = textCtrl:getStringValue()
            
            -- 玩家输入中文，给提示并清空已输入密码
            if not gf:isOnlyLetterDigital(str) then
                gf:ShowSmallTips(CHS[4200033])
                local cleanButton = dlg:getControl("CleanFieldButton", nil, panel)
                dlg:onCleanFieldButton(cleanButton)
                return
            end
            
            local targetLen = gf:getTextLength(str)
            local curStrLen = gf:getTextLength(dlg:getLabelText("PasswordLabel", panel))

            if curStrLen < targetLen then
                -- 当前显示串长度小于目标串长度（新的输入）
                local showStr = string.rep("*", targetLen - 1) .. string.sub(str, targetLen, targetLen)
                dlg:setLabelText("PasswordLabel", showStr, panel)

                performWithDelay(dlg.root, function()
                    local curLen = gf:getTextLength(textCtrl:getStringValue())
                    if curLen == targetLen then
                        -- 1s后，没有新的输入，尝试把最后一个字符置为*
                        dlg:setLabelText("PasswordLabel", string.rep("*", targetLen), panel)
                    end
                end, 1)
            elseif curStrLen > targetLen then
                -- 当前显示串长度大于目标串长度（删除）
                dlg:setLabelText("PasswordLabel", string.rep("*", targetLen), panel)
            end
        end
    end, dlgUpHeight)
end

-- 安全锁密码条件判断
function SafeLockMgr:isMeetCondition(code)
    if code == "" then
        gf:ShowSmallTips(CHS[4200037])
        return false
    end

    if gf:getTextLength(code) < 4 then
        gf:ShowSmallTips(CHS[4200038])
        return false
    end

    if not gf:isOnlyLetterDigital(code) then
        gf:ShowSmallTips(CHS[4200033])
        return false
    end

    return true
end

-- 请求打开安全锁界面
function SafeLockMgr:cmdOpenSafeLockDlg(type)
    gf:CmdToServer("CMD_SAFE_LOCK_OPEN_DLG", {type = type})
end

function SafeLockMgr:getPwdByLock(key, pwd)
    pwd = string.upper(pwd)
    local md5 = gfGetMd5(pwd)
    local password = gfEncrypt(md5, key)
    return password
end

-- 请求设置密码
function SafeLockMgr:cmdSetSafeLockPwd(key, pwd)
    local password = SafeLockMgr:getPwdByLock(key, pwd)
    gf:CmdToServer("CMD_SAFE_LOCK_SET", {key = key, pwd = password})
end

-- 请求修改密码
function SafeLockMgr:cmdChangeSafeLockPwd(key, old_pwd, new_pwd)
    local old_password = SafeLockMgr:getPwdByLock(key, old_pwd)
    local new_password = SafeLockMgr:getPwdByLock(key, new_pwd)
    gf:CmdToServer("CMD_SAFE_LOCK_CHANGE", {key = key, old_pwd = old_password, new_pwd = new_password})
end

-- 请求解锁
function SafeLockMgr:cmdUnLockSafeLock(key, pwd)
    local password = SafeLockMgr:getPwdByLock(key, pwd)
    gf:CmdToServer("CMD_SAFE_LOCK_UNLOCK", {key = key, pwd = password})
end

-- 请求或取消强制解锁
function SafeLockMgr:cmdResetSafeLock(flag)
    gf:CmdToServer("CMD_SAFE_LOCK_RESET", {flag = flag})
end

-- 是否需要验证
function SafeLockMgr:isToBeRelease(item)
    if item and item.attrib then 
        if item.attrib:isSet(ITEM_ATTRIB.ITEM_CHECK_SAFE_LOCK) then
            -- 物品需要验证
            if not self:isNeedUnLock() then
                -- 已经验证或者没有设置，就是安全锁设置不需要验证了
                return false
            else
                SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
                return true
            end
        else
            -- 该物品不需要用到
            return false
        end
    end

    if self:isNeedUnLock() then
        -- 需要验证
        SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
        return true
    end

    -- 不需要验证
    return false
end

function SafeLockMgr:isNeedUnLock()
    if SafeLockMgr.lockInfo and SafeLockMgr.lockInfo.lockState ~= SAFE_LOCK_STATE.NO_LOCK and SafeLockMgr.lockInfo.isReleaseLock == 0 then
        return true
    end

    return false
end

-- 最后一次请求的key值
local lastReleaseEvent = nil

-- 添加窗口继续函数
function SafeLockMgr:addContinueCb(dlgName, funcName, ...)
    if not dlgName then
        -- 没有传入窗口名
        return
    end

    if not funcName then
        -- 没有函数名
        return;
    end

    local arg = { ... }

    -- 清除上一次的事件
    self:clearLastRelaseEvent()

    -- 缓存新的请求
    lastReleaseEvent = {
        ["type"]    = CONTINUE_TYPE.FROM_DLG,
        ["module"]  = dlgName,
        ["cb"]      = function()
            DlgMgr:sendMsg(dlgName, funcName, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6])
        end,
    }

    -- 添加事件
    Log:D("添加事件：" .. lastReleaseEvent.module)
    EventDispatcher:addEventListener(lastReleaseEvent.module, lastReleaseEvent.cb)
end

-- 添加模块继续函数
function SafeLockMgr:addModuleContinueCb(module, funcName, ...)
    if not module then
        -- 没有传入窗口名
        return
    end

    if not funcName then
        -- 没有函数名
        return;
    end

    local arg = { ... }

    -- 清除上一次的事件
    self:clearLastRelaseEvent()

    local cb = nil
    if "function" == type(funcName) then
        cb = funcName
    else
        cb = function()
            gfCallFuncEx(string.format("%s:%s", module, funcName), arg[1], arg[2], arg[3], arg[4], arg[5], arg[6])
        end
    end

    -- 缓存新的请求
    lastReleaseEvent = {
        ["type"]    = CONTINUE_TYPE.FROM_MODULE,
        ["module"]  = module,
        ["cb"]      = cb,
    }

    -- 添加事件
    Log:D("添加事件：" .. lastReleaseEvent.module)
    EventDispatcher:addEventListener(lastReleaseEvent.module, lastReleaseEvent.cb)
end

-- 移除上一次请求的数据
function SafeLockMgr:clearLastRelaseEvent()
    if not lastReleaseEvent then
        -- 当前没有事件
        return
    end

    -- 移除上一个key的事件
    self:removeContinueCb(lastReleaseEvent.module)
    lastReleaseEvent = nil
end

-- 通过模块名删除继续函数
function SafeLockMgr:removeContinueCbByModule(module)
    if not lastReleaseEvent then
        -- 当前没有事件
        return
    end

    if lastReleaseEvent.module ~= module then
        -- 不是传入窗口的回调
        return
    end

    self:removeContinueCb(module)
    lastReleaseEvent = nil
end

-- 删除继续函数
function SafeLockMgr:removeContinueCb(module)
    if not lastReleaseEvent then
        -- 当前没有事件
        return
    end

    if not module then
        -- 传入的参数错误
        return
    end

    if lastReleaseEvent.module ~= module then
        -- 不是传入窗口的回调
        return
    end

    Log:D("移除事件：" .. lastReleaseEvent.module)
    EventDispatcher:removeEventListener(lastReleaseEvent.module, lastReleaseEvent.cb)
end

-- 分发事件
function SafeLockMgr:dispatchReleaseEvent()
    if not lastReleaseEvent then
        return
    end

    Log:D("分发事件：" .. lastReleaseEvent.module)
    EventDispatcher:dispatchEvent(lastReleaseEvent.module)
end

function SafeLockMgr:MSG_SAFE_LOCK_INFO(data)
    self.lockInfo = data
    if data.has_pwd == 0 then
        self.lockInfo.lockState = SAFE_LOCK_STATE.NO_LOCK  -- 未设置
    else
        if data.reset_end < gf:getServerTime() then
            self.lockInfo.lockState = SAFE_LOCK_STATE.BE_LOCK  -- 已设置
        else
            self.lockInfo.lockState = SAFE_LOCK_STATE.FORCE_TO_UNLOCL
        end
    end

    if 1 == data.isReleaseLock then
        -- 安全锁已经被解除
        -- 分发安全锁被解除的事件
        Log:D("安全锁已经被解除 ... ")
        self:dispatchReleaseEvent()

        -- 必须要执行的逻辑
        self:clearLastRelaseEvent()
    end
end

-- 设置安全锁信息
function SafeLockMgr:MSG_SAFE_LOCK_OPEN_SET(data)
    self.setLockInfo = data
    DlgMgr:openDlg("SafeLockSetDlg")
end

function SafeLockMgr:MSG_SAFE_LOCK_OPEN_CHANGE(data)
    self.changeLockInfo = data
    DlgMgr:openDlg("SafeLockModifyDlg")
end

function SafeLockMgr:MSG_SAFE_LOCK_OPEN_UNLOCK(data)
    self.releaseLockInfo = data

    if DlgMgr:getDlgByName("ChargeDrawGiftDlg") or DlgMgr:getDlgByName("NewChargeDrawGiftDlg") then
        local dlg = DlgMgr:getDlgByName("ChargeDrawGiftDlg") or DlgMgr:getDlgByName("NewChargeDrawGiftDlg")
        dlg.isCartooning = false
        dlg:setCtrlEnabled("OneButton", true)
        dlg:setCtrlEnabled("TenButton", true)
    end

    DlgMgr:openDlg("SafeLockReleaseDlg", nil, true)
end

function SafeLockMgr:MSG_SAFE_LOCK_OPEN_BAN(data)
    local dlg = DlgMgr:openDlg("SafeLockLimitDlg")
    dlg:setHourglass(data.ban_time)

    -- 清除对应的回调数据
    self:clearLastRelaseEvent()
end

MessageMgr:regist("MSG_SAFE_LOCK_INFO", SafeLockMgr)
MessageMgr:regist("MSG_SAFE_LOCK_OPEN_SET", SafeLockMgr)
MessageMgr:regist("MSG_SAFE_LOCK_OPEN_CHANGE", SafeLockMgr)
MessageMgr:regist("MSG_SAFE_LOCK_OPEN_UNLOCK", SafeLockMgr)
MessageMgr:regist("MSG_SAFE_LOCK_OPEN_BAN", SafeLockMgr)

return GiftMgr
