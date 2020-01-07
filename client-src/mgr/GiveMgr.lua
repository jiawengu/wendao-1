-- GiveMgr.lua
-- Created by songcw Aug/24/2016
-- 赠送管理器

GiveMgr = Singleton()

-- 发起赠送请求
function GiveMgr:tryRequestGiving(friend)
    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addModuleContinueCb("GiveMgr", "tryRequestGiving", friend)
        return
    end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000071])
        return
    end

    if Me:queryBasicInt("level") < 50 then
        gf:ShowSmallTips(CHS[4200169])
        return
    end

    if not friend or not friend.level or tonumber(friend.level) < 50 then
        gf:ShowSmallTips(CHS[4200170])
        return
    end

    GiveMgr:requestGiving(friend.gid)
end

-- 发起赠送请求
function GiveMgr:requestGiving(gid)
    gf:CmdToServer("CMD_REQUEST_GIVING", {gid = gid})
end

-- 取消赠送请求
function GiveMgr:cancelGiving()
    gf:CmdToServer("CMD_CANCEL_GIVING", {})
end

-- 同意赠送请求
function GiveMgr:accecpGiving()
    gf:CmdToServer("CMD_ACCEPT_GIVING", {})
end

-- 同意请求，打开赠送界面
function GiveMgr:openGiving()
    gf:CmdToServer("CMD_OPEN_GIVING_WINDOW", {})
end

-- 提交赠送物品  type （背包：1，宠物：2，卡套：3）
function GiveMgr:submitGiveingItem(type, pos)
    gf:CmdToServer("CMD_SUBMIT_GIVING_ITEM", {type = type, pos = pos})
end

-- 通知双方发起了赠送请求
function GiveMgr:MSG_REQUEST_GIVING(data)
    local dlg = DlgMgr:openDlg("GiveApplyDlg")
    dlg:setData(data)

    if data.giver.name ~= Me:queryBasic("name") then

        -- 播放声音
        FriendMgr:playMessageSound()
    end
end

function GiveMgr:MSG_OPEN_GIVING_WINDOW(data)
    local dlg = DlgMgr:openDlg("GiveDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_REQUEST_GIVING", GiveMgr)
MessageMgr:regist("MSG_OPEN_GIVING_WINDOW", GiveMgr)

return GiveMgr
