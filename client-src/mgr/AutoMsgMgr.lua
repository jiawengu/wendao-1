-- AutoMsgMgr.lua
-- Created by liuhb Mar/28/2016
-- 自动发送系统消息管理器

AutoMsgMgr = Singleton()

local MSGTYPE = {
    SYSTEM_MAIL = 1,    -- 系统邮件
    ANNOUCEMENT = 2,    -- 公告
}

local AUTO_MSG_INFO = {
    [CHS[5000220]] = { type = MSGTYPE.SYSTEM_MAIL, roundTime = 168 * 60 * 60, msg = CHS[5000222], title = CHS[5000224] },
    [CHS[6400039]] = { type = MSGTYPE.SYSTEM_MAIL, roundTime = 168 * 60 * 60, msg = CHS[6400040], title = CHS[6400039], testDistOnly = true, notCrossDist = true},
    [CHS[5000221]] = { type = MSGTYPE.ANNOUCEMENT, roundTime = 30 * 60, msg = CHS[5000223]},
}

local msgInfo = {}
local annouceShedule = nil
local curId = 0
local autoMailTimeInfo = {}
local mCurSysMailData = {}

-- 更新调度
local function updateSchedule()
    -- 获取公告
    local annouceInfo = AutoMsgMgr:getMsgByType(MSGTYPE.ANNOUCEMENT)
    if not annouceInfo then
        return
    end

    local curTime = gf:getServerTime()
    for key, value in pairs(annouceInfo) do
        if (not value.lastTime or curTime - value.lastTime >= value.roundTime)
            and (not value.notCrossDist or not GameMgr:IsCrossDist()) then
            AutoMsgMgr:sendSysMsg(value.msg)
            value.lastTime = curTime
        end
    end
end

local function init()
    -- 部分渠道需要隐藏微信公众号信息
    if LeitingSdkMgr:needHideWeixinInfo() then
        AUTO_MSG_INFO[CHS[5000220]].msg = CHS[7180000]
    end
    
    -- 分类放好
    for key, value in pairs(AUTO_MSG_INFO) do
        AutoMsgMgr:insertMsg(value.type, key, value)
            end
end

function AutoMsgMgr:stop()
    if annouceShedule then
        gf:Unschedule(annouceShedule)
        annouceShedule = nil
    end
end

-- 清空信息
function AutoMsgMgr:clearData()    
    mCurSysMailData = {}
end

-- 进入游戏的时候得处理
function AutoMsgMgr:doWhenEnterGame()
    -- 获取系统邮件
    local mailInfo = AutoMsgMgr:getMsgByType(MSGTYPE.SYSTEM_MAIL)
    if not mailInfo then
        return
    end

    local needList = gf:deepCopy(mailInfo)

    local curTime = gf:getServerTime()
    local data = DataBaseMgr:selectItems("autoMsg")
    
    -- 优先使用管理器中存储的系统邮件信息；如果没有数据，则使用数据库中数据
    local gid = Me:queryBasic("gid")
    if not autoMailTimeInfo[gid] then
        autoMailTimeInfo[gid] = {}
    end
    
    if #autoMailTimeInfo[gid] ~= 0 then
        data = autoMailTimeInfo[gid]
        data.count = #autoMailTimeInfo[gid]
    end
    
    if data.count > 0 then
        for i = 1, data.count do
            local item = mailInfo[data[i].key]
            if not item or curTime - data[i].lastTime < item.roundTime then
                -- 不需要再次发送
                needList[data[i].key] = nil              
            end
        end
    end

    -- 挑选只有测试区组才发的邮件
    for key, value in pairs(needList) do
        if value.testDistOnly then -- 测试才发的邮件
            if not DistMgr:curIsTestDist() then
                needList[key] = nil
            end
        end
    end

    for key, value in pairs(needList) do
        local mailItem = value
        if mailItem then
            self:sendSysMail(mailItem.title, mailItem.msg, mailItem.roundTime)
            
            -- 每次向数据库加入某一封邮件的信息数据时，先清掉之前已有的那一封邮件的数据
            local limitStr = "`key`='" .. key .. "'"
            DataBaseMgr:deleteItems("autoMsg", limitStr)
            
            DataBaseMgr:insertItem("autoMsg", {key = key, lastTime = curTime})
            
            table.insert(autoMailTimeInfo[gid], {key = key, lastTime = curTime})
        end
    end

    if not annouceShedule then
        -- 1s执行一次
        annouceShedule = gf:Schedule(updateSchedule, 1)
    end
end

function AutoMsgMgr:restart()
end

-- 获取消息
function AutoMsgMgr:getMsgByType(type)
    return msgInfo[type]
end

-- 插入一条类型消息
function AutoMsgMgr:insertMsg(type, key, value)
    if not msgInfo[type] then
        msgInfo[type] = {}
    end

    if msgInfo[type][key] then
        return
    end

    msgInfo[type][key] = value
end

-- 发送系统消息
function AutoMsgMgr:sendSysMsg(msgStr)
    Log:D(">>>>>> 发送系统消息")
    local data = {}
    data.channel = CHAT_CHANNEL.SYSTEM
    data.id = 0
    data.name = "system"
    data.msg = msgStr
    data.time = gf:getServerTime()
    data.privilege = 0
    data.server_name = "localhost"
    data.MSG = 0x2FFF
    MessageMgr:pushMsg(data)
end

-- 发送系统邮件
function AutoMsgMgr:sendSysMail(titleStr, mailStr, saveTime)
    Log:D(">>>>>> 发送系统邮件")
    local data = {}
    data.count = 1
    local info = {}
    info.id = string.format("%d", curId)
    info.type = SystemMessageMgr.SYSMSG_TYPE.SYSTEM
    info.sender = "localhost"
    info.title = titleStr
    info.msg = mailStr
    info.attachment = ""
    info.create_time = gf:getServerTime()
    info.expired_time = gf:getServerTime() + saveTime
    info.status = SystemMessageMgr.SYSMSG_STATUS.UNREAD
    data[1] = info

    data.MSG = 0xA001
    MessageMgr:pushMsg(data)
    curId = curId + 1
end

-- 删除系统邮件
function AutoMsgMgr:deleteSysMail(mailId)
    local data = {}
    data.count = 1
    local info = {}
    info.id = string.format("%d", mailId)
    info.type = SystemMessageMgr.SYSMSG_TYPE.SYSTEM
    info.sender = "localhost"
    info.title = ""
    info.msg = ""
    info.attachment = ""
    info.create_time = 0
    info.expired_time = 0
    info.status = SystemMessageMgr.SYSMSG_STATUS.DEL
    data[1] = info

    data.MSG = 0xA001
    MessageMgr:pushMsg(data)
end

-- 阅读邮件
function AutoMsgMgr:readSysMail(msg)
    msg.create_time = msg.date
    msg.expired_time = msg.saveTime
    msg.status =  SystemMessageMgr.SYSMSG_STATUS.READ
    MessageMgr:pushMsg({MSG = 0xA001, count = 1, [1] = msg})
end

-- 复制当前客户端邮件信息
function AutoMsgMgr:copyClientSysMail(data)    
    for _, mailInfo in pairs(data) do
        if type(mailInfo.queryBasic) == "function" and mailInfo:queryBasic("sender") == "localhost" then
            mCurSysMailData[_] = mailInfo
        end
    end
end

-- 通过key值获取当前客户端模拟发送的邮件信息
function AutoMsgMgr:getClientMail(key)   
    if not key then return mCurSysMailData end

    if mCurSysMailData then
        return mCurSysMailData[key]
    end
    return 
end

-- 判断是否是本地发送的
function AutoMsgMgr:isAutoMsg(info)
    if info and info.sender == "localhost" then
        return true
    end

    return false
end

init()
