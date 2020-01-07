-- ChatDecorateMgr.lua
-- created by lixh Jan/06/2018
-- 聊天装饰管理器

ChatDecorateMgr = Singleton()

-- 正在使用的头像框装饰
ChatDecorateMgr.iconDecorateUsed = nil

-- 正在使用的聊天底框装饰
ChatDecorateMgr.chatDecorateUsed = nil

-- 头像框装饰列表
ChatDecorateMgr.iconDecorateList = {}

-- 聊天底框装饰列表
ChatDecorateMgr.chatDecorateList = {}

-- 判断装饰入口是否打开
function ChatDecorateMgr:isEntrenceOpend()
    return #self.iconDecorateList > 0 or #self.chatDecorateList > 0
end

-- 设置聊天装饰入口开关
function ChatDecorateMgr:setEntranceStatus(status)
    local dlg = DlgMgr:getDlgByName("ChannelDlg")
    if dlg then
        if dlg.channelPanelTable["WorldCheckBox"] then
            dlg.channelPanelTable["WorldCheckBox"]:setDecorateBtnVisible(status)
        end
    end
end

-- 判断头像框是否过期
function ChatDecorateMgr:isIconTimeOver(name)
    for i = 1, #self.iconDecorateList do
        if name and name == self.iconDecorateList[i].name and tonumber(self.iconDecorateList[i].time) ~= -1 and
            gf:getServerTime() > tonumber(self.iconDecorateList[i].time) then
            return true
        end
    end

    return false
end

-- 判断聊天框是否过期
function ChatDecorateMgr:isChatTimeOver(name)
    for i = 1, #self.chatDecorateList do
        if name and name == self.chatDecorateList[i].name and tonumber(self.chatDecorateList[i].time) ~= -1 and
            gf:getServerTime() > tonumber(self.chatDecorateList[i].time) then
            return true
        end
    end

    return false
end

-- 获取name对应装饰的使用期限
function ChatDecorateMgr:getDecorateLeftTime(name, isIcon)
    if name == CHS[7120044] or name == CHS[7120045] then
        -- 默认头像框，默认聊天底框，直接返回可永久使用
        return CHS[7120041]
    end

    local time
    if isIcon then
        -- 从头像框中找
        for i = 1, #self.iconDecorateList do
            if name == self.iconDecorateList[i].name then
                time = self.iconDecorateList[i].time
                break;
            end
        end
    else
        -- 从聊天框中找
        for i = 1, #self.chatDecorateList do
            if name == self.chatDecorateList[i].name then
                time = self.chatDecorateList[i].time
                break;
            end
        end
    end

    -- 返回剩余时间(可永久使用, 年-月-日   时:分)
    if not time then
        -- 没有找到，说明服务器把数据刷新了，商品已过期
        return CHS[7120046]
    elseif tonumber(time) == -1 then
        return CHS[7120041]
    else
        return gf:getServerDate("%Y-%m-%d %H:%M", tonumber(time))
    end
end

-- 获取头像框列表
function ChatDecorateMgr:getIconDecorateList()
    return self.iconDecorateList
end

-- 获取聊天框列表
function ChatDecorateMgr:getChatDecorateList()
    return self.chatDecorateList
end

-- 获取正在使用的头像框信息
function ChatDecorateMgr:getIconDecorateUsed()
    return self.iconDecorateUsed
end

-- 获取正在使用的聊天框信息
function ChatDecorateMgr:getChatDecorateUsed()
    return self.chatDecorateUsed
end

function ChatDecorateMgr:MSG_DECORATION_LIST(data)
    -- 聊天装饰
    if data.type == "chat_head" then
        self.iconDecorateList = data.list
        self.iconDecorateUsed = data.usedName
    elseif data.type == "chat_floor" then
        self.chatDecorateList = data.list
        self.chatDecorateUsed = data.usedName
    end

    if self:isEntrenceOpend() then
        self:setEntranceStatus(true)
    else
        self:setEntranceStatus(false)
    end
    
    -- 个人空间装饰
    BlogMgr:setMyDecorateInfo(data)
end

function ChatDecorateMgr:clearData()
    self.iconDecorateUsed = nil
    self.chatDecorateUsed = nil
    self.iconDecorateList = {}
    self.chatDecorateList = {}
    
    BlogMgr:clearDecorateInfo()
end

MessageMgr:regist("MSG_DECORATION_LIST", ChatDecorateMgr)