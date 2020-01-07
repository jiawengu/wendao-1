-- JiebaiMgr.lua
-- Created by yangym Mar/31/2017
-- 结拜系统管理器

JiebaiMgr = Singleton()

local RANKING =
{
    CHS[7002214],  -- 大
    CHS[6000056],  -- 二
    CHS[6000057],  -- 三
    CHS[6000058],  -- 四
    CHS[6000059],  -- 五
}

local RELATION =
{
    {CHS[7002215], CHS[7002216]},  -- 年长（哥/姐）
    {CHS[7002217], CHS[7002218]},  -- 年幼（弟/妹）
}

local NUM_TO_WORD = 
{
    [2] = CHS[7002242],
    [3] = CHS[7002243],
    [4] = CHS[7002244],
    [5] = CHS[7002245],
}

function JiebaiMgr:getChengWeiMidWord(num)
    return NUM_TO_WORD[num]
end

function JiebaiMgr:getJiebaiChengwei(ranking, gender, isOlder)
    local rankingStr = RANKING[ranking]
    
    local generation
    if isOlder then
        generation = 1
    else
        generation = 2
    end
    
    local relationStr = RELATION[generation][gender]
    if rankingStr and relationStr then
        return rankingStr .. relationStr
    end
end

-- 是否拥有结拜关系
function JiebaiMgr:hasJiebaiRelation()
    if Me:queryBasic("brother/appellation") ~= "" then
        return true
    else
        return false
    end
end

-- 根据服务器发送的兄弟姐妹信息为各个角色添加称谓
function JiebaiMgr:insertChengWeiByData(data, hostGid)
    if not data then
        return
    end
    if not hostGid then hostGid = Me:queryBasic("gid") end    
    
    local meIndex = #data + 1
    for i = 1, #data do
        if hostGid ~= data[i].gid then
            local gender = tonumber(gf:getGenderByIcon(data[i].icon))
            local isOlder = (i < meIndex)
            data[i].chengWei = JiebaiMgr:getJiebaiChengwei(i, gender, isOlder)        
        else
            data[i].chengWei = CHS[7002237]
            meIndex = i
        end
    end
    
    return data
end

-- 返回结拜兄弟姐妹相关信息（不包括自己）
function JiebaiMgr:getJiebaiInfo()
    local data = self.jiebaiInfo
    local jiebaiInfo = {}
    
    if not data then
        return jiebaiInfo
    end
    
    -- 标记一下我在结拜兄弟姐妹中的位置
    local meIndex = #data + 1
    
    for i = 1, #data do
        if Me:queryBasic("gid") ~= data[i].gid then
            local info = {}
            info.name = data[i].name
            info.gid = data[i].gid
            info.icon = data[i].icon
            info.relation = CHS[7002211]
            info.friend = data[i].friend
            
            -- 获取结拜关系中的显示称谓
            local gender = tonumber(gf:getGenderByIcon(data[i].icon))
            local isOlder = (i < meIndex)
            info.showRelation = JiebaiMgr:getJiebaiChengwei(i, gender, isOlder)
            table.insert(jiebaiInfo, info)
        else
            -- 更新我在兄弟姐妹中的位置
            meIndex = i
        end
    end
    
    return jiebaiInfo
end

function JiebaiMgr:queryJiebaiInfo()
    gf:CmdToServer("CMD_REQUEST_BROTHER_INFO")
end

function JiebaiMgr:clearData(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        self.jiebaiInfo = nil
    end
end

function JiebaiMgr:MSG_REQUEST_BROTHER_INFO(data)
    self.jiebaiInfo = data
end

function JiebaiMgr:MSG_OPEN_BROTHER_DLG(data)
    
end

function JiebaiMgr:MSG_BROTHER_ORDER(data)
    local dlg = DlgMgr:openDlg("JiebSortOrderDlg")
    dlg:setInfo(data)
end

function JiebaiMgr:MSG_CANCEL_BROTHER(data)
    DlgMgr:closeDlg("JiebSortOrderDlg")
    DlgMgr:closeDlg("JiebSetTitleDlg")
    DlgMgr:closeDlg("JiebVoteDlg")
    
    -- 如果取消了当前结拜，需要取消当前的录音
    ChatMgr:cancelCurRecord()
end

function JiebaiMgr:MSG_BROTHER_APPELLATION(data)
    -- 到达设定称谓界面，需要取消“长幼排序界面”正在进行的录音
    ChatMgr:cancelCurRecord()
    
    local dlg = DlgMgr:openDlg("JiebSetTitleDlg")
    dlg:setInfo(data)
    
    DlgMgr:closeDlg("JiebSortOrderDlg")
end

function JiebaiMgr:MSG_RAW_BROTHER_INFO(data)
    -- 到达确认界面，需要取消“设定称谓界面”正在进行的录音
    ChatMgr:cancelCurRecord()
    
    local dlg = DlgMgr:openDlg("JiebVoteDlg")
    dlg:setInfo(data)
    
    DlgMgr:closeDlg("JiebSetTitleDlg")
end

function JiebaiMgr:MSG_OPEN_BROTHER_DLG(data)
    local dlg = DlgMgr:openDlg("JiebVoteDlg")
    dlg:setInfo(data, true)
end

function JiebaiMgr:doWhenEnterForeground()
    -- 结拜对话框无法主动关闭，如果因为切后台导致服务器主动关闭对话框的消息没有被处理，则由客户端关闭相关对话框
    DlgMgr:closeDlg("JiebSortOrderDlg")
    DlgMgr:closeDlg("JiebSetTitleDlg")
    DlgMgr:closeDlg("JiebVoteDlg")
end

-- 聊天泡泡
function JiebaiMgr:chatPop(panel, msg, offsetX, offsetY, showTime)
    if not self.chatContent then
        self.chatContent = {}
    end

    local name = panel:getName()
    if not self.chatContent[name] then
        self.chatContent[name] = {}
    end

    local dlg = DlgMgr:openDlg("PopUpDlg")
    local bg = dlg:addTip(msg)
    bg:setPosition(offsetX, offsetY)

    local cb = function()
        for k, v in pairs(self.chatContent[name]) do
            if v == bg then
                table.remove(self.chatContent[name], k)
            end
        end
    end

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(showTime),
        cc.CallFunc:create(cb),
        cc.RemoveSelf:create()
    )

    panel:addChild(bg)

    if #(self.chatContent[name]) == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        local node = self.chatContent[name][1]
        node:runAction(newAction)
    elseif #(self.chatContent[name]) > 1 then
        -- 消息到达2条时，移除对头消息, 并拿出新的队头继续向上移动
        local node = table.remove(self.chatContent[name], 1)
        node:stopAllActions()
        node:removeFromParent()
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        node = self.chatContent[name][1]
        node:runAction(newAction)
    end

    bg:runAction(action)
    table.insert(self.chatContent[name], bg)
end

MessageMgr:regist("MSG_REQUEST_BROTHER_INFO", JiebaiMgr)
MessageMgr:regist("MSG_OPEN_BROTHER_DLG", JiebaiMgr)
MessageMgr:regist("MSG_BROTHER_ORDER", JiebaiMgr)
MessageMgr:regist("MSG_CANCEL_BROTHER", JiebaiMgr)
MessageMgr:regist("MSG_BROTHER_APPELLATION", JiebaiMgr)
MessageMgr:regist("MSG_RAW_BROTHER_INFO", JiebaiMgr)
MessageMgr:regist("MSG_OPEN_BROTHER_DLG", JiebaiMgr)

return JiebaiMgr