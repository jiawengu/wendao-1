-- SystemMessageMgr.lua
-- Created by liuhb Mar/02/2015
-- 系统消息管理器

local DataObject = require("core/DataObject")
SystemMessageMgr = Singleton()

SystemMessageMgr.sysMsgs = {}
SystemMessageMgr.oldMsgs = {}
SystemMessageMgr.sysGroupMsgs = {}

-- 邮件类型
SystemMessageMgr.SYSMSG_TYPE = {
    SYSTEM          = 0,    -- 系统消息
    FRIEND_CHECK    = 1,    -- 好友验证
    ARENA           = 2,    -- 竞技场信息
    RED_DOT         = 3,    -- 小红点提示
    TYPE_MAIL_CHATGROUP = 4, -- 群组系统消息
    TYPE_MAIL_MATERIAL  = 5, -- 材料赠送
    TYPE_MAIL_ACTIVITY  = 6, -- 活动切磋战报
    TYPE_MAIL_FRIEND    = 7, -- 好友区域验证消息
}

-- 邮件操作
local SYSMSG_OPERATE = {
    READ    = 0,    -- 阅读
    GETACC  = 1,    -- 领取附件
    DEL     = 2,    -- 删除邮件
}

-- 邮件状态
SystemMessageMgr.SYSMSG_STATUS = {
    UNREAD  = 0,
    READ    = 1,
    GET     = 2,
    DEL     = 3,
}

-- 邮件上限数量
local SYSTEM_MAIL_SHOW_MAX = 50

-- 获取系统邮件列表最大显示数量
function SystemMessageMgr:getSysMailShowMax()
    return SYSTEM_MAIL_SHOW_MAX
end

SystemMessageMgr.SYSMSG_GROUP_TITLE = {
    REMOVE       = "1",   -- 移除群信息
    DISMISS      = "2",   -- 解散群信息
    DISMISS_SELF = "3",   -- 自身解散群信息
    QUIT         = "4",   -- 退出群信息
    QUIT_SELF    = "5",   -- 自身退出群信息
    INVENTE      = "6",   -- 群邀请信息
    REFUSE       = "7",   -- 拒绝群邀请
    ACCEPT       = "8",   -- 接受群邀请
}

function SystemMessageMgr:clearData(isLoginOrSwithLine)
    -- 客户端模拟发送邮件换线后情况所以，换线时先记录下由客户端模拟发送的邮件信息，详见任务WDSY-17396
    if DistMgr:getIsSwichServer() then
        AutoMsgMgr:copyClientSysMail(self.sysMsgs)
    else
        AutoMsgMgr:clearData()
    end

    if isLoginOrSwithLine then
        -- 保存旧的邮件数据，用于判断换线时收到的邮件是否新的邮件
        if next(self.sysMsgs) then
            self.oldMsgs["sysMsgs"] = self.sysMsgs
        end

        if next(self.sysGroupMsgs) then
            self.oldMsgs["sysGroupMsgs"] = self.sysGroupMsgs
        end
    else
        self.oldMsgs = {}
    end

    self.sysMsgs = {}
    self.sysGroupMsgs = {}
    self.mailIsLoaded = false
end

function SystemMessageMgr:isNewSysMsg(msg)
    local isOld = false
    for _, v in pairs(self.oldMsgs) do
        if v[msg.id] then
            isOld = true
            break
        end
    end

    return not isOld
end


function SystemMessageMgr:needCheckReddot(msg)
    if not self:getIsSwichServer() or self:isNewSysMsg(msg) then
        return true
    end
end

-- 过滤掉过期邮件
function SystemMessageMgr:updateAllMessage()
    for key, value in pairs(SystemMessageMgr.sysMsgs) do
        local time = value:queryBasicInt("expired_time")
        local curTime = gf:getServerTime()

        if time <= curTime then
            local type = SystemMessageMgr.sysMsgs[key]:queryInt("type")

            SystemMessageMgr.sysMsgs[key] = nil
            MessageMgr:pushMsg({MSG = 0xA001, count = 1, {id = key, status = SystemMessageMgr.SYSMSG_STATUS.DEL, type = type}})
        end
    end
end

-- 更新系统消息
function SystemMessageMgr:updateSystemMessage(data)
    if not data or not data.id then
        return
    end

    -- 删除标记为del的邮件
    if (data.type == SystemMessageMgr.SYSMSG_TYPE.SYSTEM or data.type == SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK) and SystemMessageMgr.SYSMSG_STATUS.DEL == data.status then
        self.sysMsgs[data.id] = nil
        local clientMail = AutoMsgMgr:getClientMail()
        clientMail[data.id] = nil
        return
    end

    if data.type == SystemMessageMgr.SYSMSG_TYPE.ARENA
        or data.type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_ACTIVITY then
        -- 竞技场消息，由竞技场管理器负责处理
        ArenaMgr:updateMailMsg(data)
        return
    end

    if data.type == SystemMessageMgr.SYSMSG_TYPE.RED_DOT then
        -- 小红点消息，由小红点负责处理
        RedDotMgr:updateMailRedDot(data)
        return
    end

    -- 群组信息
    if data.type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_CHATGROUP then
        self:updateGroupMessage(data)
        return
    end

    -- 区域好友验证申请
    if data.type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_FRIEND then
        CitySocialMgr:updateVerifyMessage(data)
        return
    end

    if data.type == SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK then
        if self:needCheckReddot(data) then
            RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
            RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton")
            RedDotMgr:insertOneRedDot("FriendDlg", "NewFriendButton")
            RedDotMgr:insertOneRedDot("FriendDlg", "FriendCheckBox")
            DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton")

            local dlg = DlgMgr:getDlgByName("FriendDlg")
            if dlg and dlg.idx ~= 10 then
                -- 如果当前打开的不是好友验证面板则加入小红点
                RedDotMgr:insertOneRedDot("FriendDlg", "FriendReturnButton")
            end
        else
            RedDotMgr:insertOneRedDot("FriendDlg", "NewFriendButton")
        end
    elseif data.status == SystemMessageMgr.SYSMSG_STATUS.UNREAD and self:needCheckReddot(data) then
        RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
        RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton")
        RedDotMgr:insertOneRedDot("FriendDlg", "MailCheckBox")
        DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton")
        FriendMgr:playMessageSound()
    end

    local sysMsg = self.sysMsgs[data.id]
    if not sysMsg then
        sysMsg = DataObject.new()
        self.sysMsgs[data.id] = sysMsg
    end

    sysMsg:absorbBasicFields(data)
end

-- 群系统消息
function SystemMessageMgr:updateGroupMessage(data)
    if not self.sysGroupMsgs then self.sysGroupMsgs = {} end
    self.sysGroupMsgs[data.id] = data

    if SystemMessageMgr.SYSMSG_STATUS.DEL == data.status  then
        self.sysGroupMsgs[data.id] = nil
    else
        if data.title == self.SYSMSG_GROUP_TITLE.REFUSE or data.title == self.SYSMSG_GROUP_TITLE.ACCEPT then -- 同意或者拒绝的返回消息
            local list = gf:split(data.msg, ";")
            local leaderId = list[1]
            local groupId = list[2] -- 群组id
            local memberId = list[3]
            FriendMgr:deleteInviteMember(groupId, memberId)
        end

        if self:needCheckReddot(data) then
            if self:isGroupVerifyMsg(data) or data.status == SystemMessageMgr.SYSMSG_STATUS.UNREAD then
                RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
                RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton")
                RedDotMgr:insertOneRedDot("FriendDlg", "GroupCheckBox")
                RedDotMgr:insertOneRedDot("FriendDlg", "GroupNewsButton")
                DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton")

                local dlg = DlgMgr:getDlgByName("FriendDlg")
                if dlg and dlg.idx ~= 11 then
                    -- 如果当前打开的不是群验证面板则加入小红点
                    RedDotMgr:insertOneRedDot("FriendDlg", "GroupReturnButton")
                end
            end
        end
    end
end

-- 是否有群验证消息(在上线时候)
function SystemMessageMgr:isGroupVerifyMsg(mail)
    if not self:getIsSwichServer()
          and not self.mailIsLoaded
          and mail.type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_CHATGROUP
          and mail.title == self.SYSMSG_GROUP_TITLE.INVENTE then -- 群邀请信息
        local list = gf:split(mail.msg, ";")
        if list[5] == "0" then -- 未操作
            return true
        end
    end

    return false
end


function SystemMessageMgr:getGroupMessage()
    local messageList = {}

    local function sortTime(l, r)
        return l.create_time < r.create_time
    end

    if self.sysGroupMsgs then
        for k, v in pairs(self.sysGroupMsgs) do
            table.insert(messageList, v)
        end
    end

    table.sort(messageList, sortTime)

    return messageList
end

function SystemMessageMgr:getOnGroupMessageInfo(id)
    return self.sysGroupMsgs[id]
end

-- 是否存在还有附件的邮件
function SystemMessageMgr:hasSystemMessageAcc()
    for key, value in pairs(SystemMessageMgr.sysMsgs) do
        local status = value:queryBasicInt("status")
        local attachment = value:queryBasic("attachment")
        if status ~= SystemMessageMgr.SYSMSG_STATUS.GET and not self:isAttachmentEmpty(attachment) then
            return true
        end
    end

    return false
end

-- 该有是否有附件没领取
function SystemMessageMgr:notGetAcc(id)
    local msg = self:getSystemMessageById(id)
    if msg then
        local status = msg["status"]
        local attachment = msg["attachment"]
        if status ~= SystemMessageMgr.SYSMSG_STATUS.GET and not self:isAttachmentEmpty(attachment) then
            return true
        end
    end
end

-- 该邮件是否需要玩家提交个人有效信息
function SystemMessageMgr:checkNeedSubmitMsg(id)
    local msg = self:getSystemMessageById(id)
    if msg then
        local status = msg["status"]
        local attachment = msg["attachment"]
        if status ~= SystemMessageMgr.SYSMSG_STATUS.GET
            and nil ~= attachment
            and "" ~= attachment
            and (string.match(attachment, "{NeedGather=(%d+).*}")
                or string.match(attachment, "{NeedPhone=(%d+).*}")
                or string.match(attachment, "{NeedPrivilege=(%d+).*}")
                or string.match(attachment, "{NeedReward=(%d+).*}")
                or string.match(attachment, "{NeedChannel=(%d+).*}")
                or string.match(attachment, "{NeedBank=(%d+).*}")
            ) then
            return true
        end
    end
end

-- 获取提交信息时间
function SystemMessageMgr:getGatherEndTime(id)
    local msg = self:getSystemMessageById(id)
    if msg then
        local status = msg["status"]
        local attachment = msg["attachment"]
        if attachment and "" ~= attachment then

            local value = string.match(attachment, "{NeedGather=(%d+).*}")
            if not value then
                value = string.match(attachment, "{NeedPhone=(%d+).*}")
            end

            if not value then
                -- 大R玩家信息收集
                value = string.match(attachment, "{NeedPrivilege=(%d+).*}")
            end

            if not value then
                value = string.match(attachment, "{NeedReward=(%d+).*}")
            end

            if not value then
                -- 收集银行卡信息
                value = string.match(attachment, "{NeedBank=(%d+).*}")
            end
            
         
            if not value then
                value = string.match(attachment, "{NeedChannel=(%d+).*}")
            end

            return value
        end
    end
end

-- 获取提交信息类型
function SystemMessageMgr:getGatherTypeById(id)
    local msg = self:getSystemMessageById(id)
    if msg then
        local status = msg["status"]
        local attachment = msg["attachment"]
        if attachment and "" ~= attachment then
            if string.match(attachment, "{NeedGather=(%d+).*}") then
                return 1
            elseif string.match(attachment, "{NeedPhone=(%d+).*}") then
                return 2
            elseif string.match(attachment, "{NeedPrivilege=(%d+).*}") then
                return 3 -- 大R玩家信息收集
            elseif string.match(attachment, "{NeedReward=(%d+).*") then
                return 4 -- 赛事奖励信息收集
            elseif string.match(attachment, "{NeedBank=(%d+).*") then
                return 5 -- 银行卡信息收集
            elseif string.match(attachment, "{NeedChannel=(%d+).*") then
                return 6 -- 渠道更换信息收集
            end
        end
    end

    return 0
end

-- 是否存在未读邮件
function SystemMessageMgr:hasUnReadSystemMessage()
    for key, value in pairs(SystemMessageMgr.sysMsgs) do
        local status = value:queryBasicInt("status")
		-- SystemMessageMgr.SYSMSG_TYPE == value:queryBasicInt("type")  此等式恒不成立，可游戏表现竟然是正确的！！！改回去
        if status == SystemMessageMgr.SYSMSG_STATUS.UNREAD and SystemMessageMgr.SYSMSG_TYPE.SYSTEM == value:queryBasicInt("type")  then
            return true
        end
    end

    local client = AutoMsgMgr:getClientMail()
    for key, value in pairs(client) do
        local status = value:queryBasicInt("status")
        if status == SystemMessageMgr.SYSMSG_STATUS.UNREAD and SystemMessageMgr.SYSMSG_TYPE.SYSTEM == value:queryBasicInt("type")  then
            return true
        end
    end
    return false
end

-- 是否存在群信息为读
function SystemMessageMgr:hasUnReadGroupMessageAcc()
    if not self.sysGroupMsgs then return false end

    for key, value in pairs(self.sysGroupMsgs) do
        local status = value.status
        if status == SystemMessageMgr.SYSMSG_STATUS.UNREAD and SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_CHATGROUP == value.type  then
            return true
        end
    end

    return false
end

-- 邮件附件是否为空，邮件有些数据走附件逻辑，但不是奖励，需要认为是空附件
function SystemMessageMgr:isAttachmentEmpty(attachment)
    if string.isNilOrEmpty(attachment) then
        return true
    elseif string.match(attachment, "{PartyId=(.+)$NotInPartyTip=(.+)}$") then
        -- 帮派俸禄，功臣邮件附件
        return true
    elseif string.match(attachment, "{CArticleId=(.+)$CTitle=(.+)}$") then
        -- 微社区跳转邮件
        return true
    elseif SystemMessageMgr:isChildJump(attachment) then
        -- 娃娃跳转，认为没有附件
        return true
    end

    return false
end

-- 是否为微社区跳转邮件的邮件
function SystemMessageMgr:isCommunityJump(attachment)
    if not string.isNilOrEmpty(attachment) and string.match(attachment, "{CArticleId=(.+)$CTitle=(.+)}$") then
        return true
    end

    return false
end

-- 是否为娃娃跳转的邮件
function SystemMessageMgr:isChildJump(attachment)
    if not string.isNilOrEmpty(attachment) and string.match(attachment, "{ChildCid=(.+)}") then
        return true
    end

    return false
end

-- 获取微社区跳转邮件的附件信息
function SystemMessageMgr:getCommunityJumpInfo(attachment)
    if not string.isNilOrEmpty(attachment) then
        local artcleId, title = string.match(attachment, "{CArticleId=(.+)$CTitle=(.+)}$")
        if artcleId and title then
            return artcleId, title
        end
    end
end

-- 是否存在未察看的带有附件的邮件
function SystemMessageMgr:hasUnReadSystemMessageAcc()
    for key, value in pairs(SystemMessageMgr.sysMsgs) do
        local status = value:queryBasicInt("status")
        local attachment = value:queryBasic("attachment")
        if status == SystemMessageMgr.SYSMSG_STATUS.UNREAD and nil ~= attachment and "" ~= attachment then
            return true
        end
    end

    return false
end

-- 判断邮件是否过期
function SystemMessageMgr:isOverdue(id)
    local msg = self:getSystemMessageById(id)
    if msg then
        local time = msg["saveTime"]
        local curTime = gf:getServerTime()
        if time <= curTime then
            return true
        end
    end
end

-- 本地删除一封邮件
function SystemMessageMgr:deleteOneMail(id)
    local type
    if SystemMessageMgr.sysMsgs[id] then
        type = SystemMessageMgr.sysMsgs[id]:queryInt("type")
        SystemMessageMgr.sysMsgs[id] = nil
    elseif AutoMsgMgr:getClientMail(id) then
        local mail = AutoMsgMgr:getClientMail(id)
        type = mail:queryInt("type")
        mail = nil
    end

    MessageMgr:pushMsg({MSG = 0xA001, count = 1, {id = id, status = SystemMessageMgr.SYSMSG_STATUS.DEL, type = type}})
end

-- 获取系统消息
function SystemMessageMgr:getSystemMessageList()
    self.sortMsgList = self:getSystemMessageListByType(SystemMessageMgr.SYSMSG_TYPE.SYSTEM)

    -- 排序
    table.sort(self.sortMsgList, function(l, r) return self:sortFunc(l, r) end)

    self.sortMsgListCount = #self.sortMsgList
    return self.sortMsgList
end

-- 根据类型获取系统消息
function SystemMessageMgr:getSystemMessageListByType(type)
    local sortMsgList = {}
    for k, v in pairs(self.sysMsgs) do
        if SystemMessageMgr.SYSMSG_STATUS.DEL ~= v:queryBasicInt("status") and type == v:queryBasicInt("type") then
            local saveTime = v:queryBasicInt("expired_time")
            local attachment = v:queryBasic("attachment")
            local status = v:queryBasicInt("status")

            -- 首先检查是否过期
            local curTime = gf:getServerTime()
            if curTime < saveTime or ("" ~= attachment and SystemMessageMgr.SYSMSG_STATUS.GET ~= status) then
                local id = v:queryBasic("id")
                local type = v:queryBasicInt("type")
                local title = v:queryBasic("title")
                local date = v:queryBasicInt("create_time")
                local sender = v:queryBasic("sender")
                local msg = v:queryBasic("msg")
                local index = #sortMsgList + 1
                table.insert(sortMsgList, {index = index, id = id, type = type, name = title, date = date, saveTime = saveTime, status = status, attachment = attachment, sender = sender, msg = msg})
            end
        end
    end

    local clientMail = AutoMsgMgr:getClientMail()
    for k, v in pairs(clientMail) do
        if SystemMessageMgr.SYSMSG_STATUS.DEL ~= v:queryBasicInt("status") and type == v:queryBasicInt("type") then
            local saveTime = v:queryBasicInt("expired_time")
            local attachment = v:queryBasic("attachment")
            local status = v:queryBasicInt("status")

            -- 首先检查是否过期
            local curTime = gf:getServerTime()
            if curTime < saveTime or ("" ~= attachment and SystemMessageMgr.SYSMSG_STATUS.GET ~= status) then
                local id = v:queryBasic("id")
                local type = v:queryBasicInt("type")
                local title = v:queryBasic("title")
                local date = v:queryBasicInt("create_time")
                local sender = v:queryBasic("sender")
                local msg = v:queryBasic("msg")
                local index = #sortMsgList + 1
                table.insert(sortMsgList, {index = index, id = id, type = type, name = title, date = date, saveTime = saveTime, status = status, attachment = attachment, sender = sender, msg = msg})
            end
        end
    end
    return sortMsgList
end

-- WDSY-26227测试接口，不用于具体逻辑
function SystemMessageMgr:getValidAutoMsg()
    local sortMsgList = {}
    local clientMail = AutoMsgMgr:getClientMail()
    for k, v in pairs(clientMail) do
        if SystemMessageMgr.SYSMSG_STATUS.DEL ~= v:queryBasicInt("status") and type == v:queryBasicInt("type") then
            local saveTime = v:queryBasicInt("expired_time")
            local attachment = v:queryBasic("attachment")
            local status = v:queryBasicInt("status")

            -- 首先检查是否过期
            local curTime = gf:getServerTime()
            if curTime < saveTime or ("" ~= attachment and SystemMessageMgr.SYSMSG_STATUS.GET ~= status) then
                local id = v:queryBasic("id")
                local type = v:queryBasicInt("type")
                local title = v:queryBasic("title")
                local date = v:queryBasicInt("create_time")
                local sender = v:queryBasic("sender")
                local msg = v:queryBasic("msg")
                local index = #sortMsgList + 1
                table.insert(sortMsgList, {index = index, id = id, type = type, name = title, date = date, saveTime = saveTime, status = status, attachment = attachment, sender = sender, msg = msg})
            end
        end
    end
    return sortMsgList
end

-- 排序函数
function SystemMessageMgr:sortFunc(l, r)
    if tonumber(l.date) <= tonumber(r.date) then
        return false
    else
        return true
    end
end

-- 根据消息id获取消息信息
function SystemMessageMgr:getSystemMessageById(id)
    local msg = self.sysMsgs[id]
    if not msg then msg = AutoMsgMgr:getClientMail(id) end
    if nil == msg then return end
    local type = msg:queryBasic("type")
    local title = msg:queryBasic("title")
    local date = msg:queryBasicInt("create_time")
    local saveTime = msg:queryBasicInt("expired_time")
    local text = msg:queryBasic("msg")
    local status = msg:queryBasicInt("status")
    local attachment = msg:queryBasic("attachment")
    local sender = msg:queryBasic("sender")
    return {id = id, type = type, name = title, date = date, saveTime = saveTime, msg = text, status = status, attachment = attachment, sender = sender, title = title}
end

-- 对系统消息进行操作
function SystemMessageMgr:operateMsg(id, operate)
    local msg = {}
    if 0 ~= id then
        msg = self:getSystemMessageById(id) or self.sysGroupMsgs[id]
    else
        msg.type = 0
        msg.id = ""
    end

    if not msg then return end

    local data = {}
    data.type = msg.type
    data.id = msg.id
    data.operate = operate
    gf:CmdToServer("CMD_MAILBOX_OPERATE", data)
end

-- 删除单条系统消息
function SystemMessageMgr:deleteSystemMessage(id)
    local msg = self:getSystemMessageById(id)
    if AutoMsgMgr:isAutoMsg(msg) then
        AutoMsgMgr:deleteSysMail(id)
        return
    end

    self:operateMsg(id, SYSMSG_OPERATE.DEL)
    -- self.sysMsgs[id] = nil

    -- MessageMgr:pushMsg({MSG = 0xA001, count = 1, {id = id, status = SystemMessageMgr.SYSMSG_STATUS.DEL}})
end

function SystemMessageMgr:deleteGroupSystemMessge(id)
    if self.sysGroupMsgs and self.sysGroupMsgs[id] then
       self:operateMsg(id, SYSMSG_OPERATE.DEL)
    end
end

-- 一键清空系统邮件
function SystemMessageMgr:deleteSystemMessageOneKey()
    self:operateMsg(0, SYSMSG_OPERATE.DEL)
end

-- 领取附件
function SystemMessageMgr:getAccessory(id)
    self:operateMsg(id, SYSMSG_OPERATE.GETACC)
end

-- 领取附件之前，需要给提示（比如vip）
function SystemMessageMgr:getRewardTips(rewardStr)
    local tips = {}

    local tip = self:getVipTips(rewardStr) -- vip 提示
    if tip then 
        table.insert(tips, tip)
    end

    local tip = self:getOfflineTips(rewardStr)  -- 离线提示
    if tip then 
        table.insert(tips, tip)
    end

    local tip = self:getZiqihongmengTips(rewardStr) -- 紫气鸿蒙提示
    if tip then 
        table.insert(tips, tip)
    end

    local tip = self:getChongfengsanTips(rewardStr) -- 宠风散点数提示
    if tip then 
        table.insert(tips, tip)
    end

    return tips
end

function SystemMessageMgr:getVipTips(rewardStr)
    local classList = TaskMgr:getRewardList(rewardStr)
    local tips = nil

    if #classList > 0 then
        local rewardList = classList[1]
        for i = 1, #rewardList do
            local oneReward = rewardList[i]
            if oneReward[1] == CHS[3004359] then
                local vipName = string.match(oneReward[2], "(.*)$Time=%d+")
                tips = OnlineMallMgr:getVipTips(vipName)
                break
            end
        end
    end

    return tips
end

-- 附件中含有某种奖励
function SystemMessageMgr:isHaveRewardByName(name, rewardStr)
    local classList = TaskMgr:getRewardList(rewardStr)
    local tips = nil

    if #classList > 0 then
        local rewardList = classList[1]
        for i = 1, #rewardList do
            local oneReward = rewardList[i]
            if string.match(oneReward[1]..oneReward[2], name) then
                return true
            end
        end
    end
end

-- 获取附件中的某一类总值（目前只取#Iname|name#rnum#I）
function SystemMessageMgr:getRewardTotalNumByName(name, rewardStr)
    local classList = TaskMgr:getRewardList(rewardStr)
    local tips = nil
    local totalNum = 0

    if #classList > 0 then
        local rewardList = classList[1]
        for i = 1, #rewardList do
            local oneReward = rewardList[i]
            if string.match(oneReward[1]..oneReward[2], name) then
                local list = gf:split(oneReward[2], "#r")
                if list and tonumber(list[2]) then
                    totalNum = totalNum + tonumber(list[2])
                end
            end
        end
    end

    return totalNum
end

-- 领取离线时间提示
function SystemMessageMgr:getOfflineTips(rewardStr)
    local tips = nil
    local rewardTotal = self:getRewardTotalNumByName(CHS[6200024], rewardStr)
    local have =  GetTaoMgr:getAllOfflineTime()
    if rewardTotal + have > GetTaoMgr:getMaxOfflineTime() * 60 then
        local over = (rewardTotal + have) - GetTaoMgr:getMaxOfflineTime() * 60
        local min = math.floor(over / 60)
        local sec = over % 60
        tips = string.format(CHS[6200025], GetTaoMgr:getMaxOfflineTime(), self:getTimeStr(over))
    end

    return tips
end

-- 领取紫气鸿蒙点数提示
function SystemMessageMgr:getZiqihongmengTips(rewardStr)
    local tips = nil
    local rewardTotal = self:getRewardTotalNumByName(CHS[7000284], rewardStr)
    local point = GetTaoMgr:getAllZiQiHongMengPoint() + rewardTotal - GetTaoMgr:getMaxZiQiHongMengPoint()
    if point > 0 and rewardTotal > 0 then
        -- 继续领取超出的紫气鸿蒙点数被没收
        tips = string.format(CHS[7000299], GetTaoMgr:getMaxZiQiHongMengPoint(), point)
    end

    return tips
end

-- 领取宠风散点数提示
function SystemMessageMgr:getChongfengsanTips(rewardStr)
    local tips = nil
    local rewardTotal = self:getRewardTotalNumByName(CHS[5420304], rewardStr)
    local point = GetTaoMgr:getPetFengSanPoint() + rewardTotal - GetTaoMgr:getMaxChongFengSanPoint()
    if point > 0 and rewardTotal > 0 then
        -- 继续领取超出的宠风散点数被没收
        tips = string.format(CHS[5420308], GetTaoMgr:getMaxChongFengSanPoint(), point)
    end

    return tips
end

function SystemMessageMgr:getTimeStr(time)
    local str = ""
    local min = math.floor(time / 60)
    local sec = time % 60

    if min > 0 then
        str = min .. CHS[6200023]
    end

    if sec > 0 then
        str = str .. sec .. CHS[3002392]
    end

    return str
end

-- 标志群组全部已读
function SystemMessageMgr:redAllGgroupMsg()
    if not self.sysGroupMsgs then return end

    for k, v in pairs(self.sysGroupMsgs)do
        if v.status == SystemMessageMgr.SYSMSG_STATUS.UNREAD  then
            self:readMsg(v.id)
        end
    end
end

-- 标记已读
function SystemMessageMgr:readMsg(id)
    if self.sysGroupMsgs and self.sysGroupMsgs[id] then
        -- 群组消息特殊处理
        self:operateMsg(id, SYSMSG_OPERATE.READ)
        return true
    end

    local msg = self:getSystemMessageById(id)
    if not msg then return end  -- 没有邮件
    if self:isOverdue(id) then -- 过期读邮件服务端没有响应客户端自己响应
        msg.create_time = msg.date
        msg.expired_time = msg.saveTime
        msg.status =  SystemMessageMgr.SYSMSG_STATUS.READ
        MessageMgr:pushMsg({MSG = 0xA001, count = 1, [1] = msg})
        return true
    else
        if AutoMsgMgr:isAutoMsg(msg) then
            AutoMsgMgr:readSysMail(msg)
            return true
        end

        self:operateMsg(id, SYSMSG_OPERATE.READ)
        return true
    end
end

-- 一键删除所有的好友验证
function SystemMessageMgr:deleteFriendCheckOneKey()
    self:deleteOneTypeAllMessage(SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK)
end

-- 一键删除所有的区域好友验证
function SystemMessageMgr:deleteAllCityFriendCheck()
    self:deleteOneTypeAllMessage(SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_FRIEND)
end

-- 一键删除所有的群组信息
function SystemMessageMgr:deleteAllGroupSystemMsg()
    self:deleteOneTypeAllMessage(SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_CHATGROUP)
end

function SystemMessageMgr:deleteOneTypeAllMessage(type)
    local data = {}
    data.type = type
    data.id = ""
    data.operate = SYSMSG_OPERATE.DEL
    gf:CmdToServer("CMD_MAILBOX_OPERATE", data)
end

function SystemMessageMgr:MSG_MAILBOX_REFRESH(data)
    if nil == data or data.count <= 0 then return end

    local count  = data.count
    for i = 1, count do
        self:updateSystemMessage(data[i])
    end
end

-- 是否换线
-- 在这边再加个邮件模块的是否换线，原因是DistMgr:getIsSwichServer在NOTIFY_SEND_INIT_DATA_DONE重置
-- 由于邮件服务器是异步加载所以没有办法在NOTIFY_SEND_INIT_DATA_DONE发完
-- 所以需要在再弄个标志
function SystemMessageMgr:getIsSwichServer()
    return self.isSwichServer
end

function SystemMessageMgr:setIsSwichServer(isSwichServer)
    self.isSwichServer = isSwichServer
end

function SystemMessageMgr:MSG_GENERAL_NOTIFY(data)
    if data.notify == NOTIFY.NOTIFY_MAIL_ALL_LOADED then
        self:setIsSwichServer(false)
        self.mailIsLoaded = true

        -- 加载好友界面
        if not DlgMgr:getDlgByName("FriendDlg") and GameMgr.initDataDone then
            local dlg = DlgMgr:openDlg("FriendDlg")
            dlg:setVisible(false)

            if dlg.systemMessageDlg then
                dlg.systemMessageDlg:logReport()
        end
        else
            local dlg = DlgMgr:getDlgByName("FriendDlg")
            if dlg and dlg.systemMessageDlg and GameMgr.initDataDone then
                dlg.systemMessageDlg:logReport()
    end
        end
    end
end

function SystemMessageMgr:getMailIsLoad()
    return self.mailIsLoaded
end

function SystemMessageMgr:getMailAmount()
    local totalMsg, unReadMsg = 0, 0

    local function statisticMailAmount(msg) -- 统计总邮件数和未读邮件数
        local status, type = msg:queryBasicInt("status"), msg:queryBasicInt("type")
        if SystemMessageMgr.SYSMSG_STATUS.UNREAD == status and SystemMessageMgr.SYSMSG_TYPE.SYSTEM == type then
            unReadMsg = unReadMsg + 1
        end
        totalMsg = totalMsg + 1
    end

    for key, msg in pairs(SystemMessageMgr.sysMsgs) do
        statisticMailAmount(msg)
    end
    for key, msg in pairs(AutoMsgMgr:getClientMail()) do
        statisticMailAmount(msg)
    end
    return totalMsg, unReadMsg
end

MessageMgr:regist("MSG_MAILBOX_REFRESH", SystemMessageMgr)
MessageMgr:hook("MSG_GENERAL_NOTIFY", SystemMessageMgr, "SystemMessageMgr")