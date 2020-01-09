-- MatchMakingMgr.lua
-- Created by sujl, Sept/21/2018
-- 相亲管理器

MatchMakingMgr = Singleton()

MatchMakingMgr.details = {}

-- 封面上传时间限制
local PORTRAIT_UPLOAD_TIME_LIMIT = 10 * 60

function MatchMakingMgr:clearData()
    self.mySetting = nil
    self.queryList = nil
    self.details = nil
end

-- 获取配置
function MatchMakingMgr:getMySetting()
    return self.mySetting or {}
end

-- 获取查询列表数据
function MatchMakingMgr:getQueryList(queryType)
    if not self.queryList then return end

    return queryType and self.queryList[queryType]
end

-- 获取列表数据
function MatchMakingMgr:getQueryDataByIndex(queryType, index)
    local list = self:getQueryList(queryType)
    if not list then return end

    return list[index]
end

-- 获取详细信息
function MatchMakingMgr:getDetail(gid)
    if not self.details then return end

    return gid and self.details[gid]
end

-- 是否某人头像
function MatchMakingMgr:isDefaultIcon()
    if self.mySetting then
        return string.isNilOrEmpty(self.mySetting.portrait)
    end

    return true
end

-- 是否已发布
function MatchMakingMgr:isPublished()
    return self.mySetting and self.mySetting.publish == 1
end

-- 检查是否可以上传
function MatchMakingMgr:canUploadCoverTime()
    local first = self.lastUploadPortrait and self.lastUploadPortrait[math.max(1, #self.lastUploadPortrait - 2)]
    if not first then return 0 end   -- 没有记录
    if gf:getServerTime() - first <= PORTRAIT_UPLOAD_TIME_LIMIT and #self.lastUploadPortrait - 2 > 0 then
        return math.ceil((PORTRAIT_UPLOAD_TIME_LIMIT - (gf:getServerTime() - first)) / 60)
    end
    return 0
end

-- 记录最近上传的图片
function MatchMakingMgr:markUploadPortrait()
    -- 只保留2张
    if not self.lastUploadPortrait then
        self.lastUploadPortrait = {}
    else
        local count = #self.lastUploadPortrait
        if count >= 3 then
            self.lastUploadPortrait[1] = self.lastUploadPortrait[count - 2]
            self.lastUploadPortrait[2] = self.lastUploadPortrait[count - 1]
        end
    end

    table.insert(self.lastUploadPortrait, gf:getServerTime())
end

function MatchMakingMgr:MSG_MATCH_MAKING_QUERY_LIST(data)
    if not self.queryList then
        self.queryList = {}
    end

    self.queryList[data.type] = data.list
    table.sort(self.queryList[data.type], function(l, r)
        return l.match > r.match
    end)
end

function MatchMakingMgr:MSG_MATCH_MAKING_DETAIL(data)
    if not self.details then
        self.details = {}
    end

    self.details[data.gid] = data
end

function MatchMakingMgr:MSG_MATCH_MAKING_SETTING(data)
    self.mySetting = data

    DlgMgr:openDlg("MatchmakingDlg")
end

function MatchMakingMgr:MSG_MATCH_MAKING_FAVORITE_RET(data)
    local detail = self:getDetail(data.gid)
    if detail then
        detail.is_collect = data.result
    end

    if 0 == data.result then
        local list = self:getQueryList(0)
        if list then
            local index
            for i = 1, #list do
                if list[i].gid == data.gid then
                    index = i
                    break
                end
            end

            if index then
                table.remove(list, index)
            end
        end
    elseif self.queryList and self.queryList[0] then
        local list = self:getQueryList(1)
        if list then
            for i = 1, #list do
                if list[i].gid == data.gid then
                    table.insert(self.queryList[0], list[i])
                    break
                end
            end
        end
    end

    if self.queryList and self.queryList[0] then
        table.sort(self.queryList[0], function(l, r)
            return l.match > r.match
        end)
    end
end

MessageMgr:regist("MSG_MATCH_MAKING_QUERY_LIST", MatchMakingMgr)
MessageMgr:regist("MSG_MATCH_MAKING_DETAIL", MatchMakingMgr)
MessageMgr:regist("MSG_MATCH_MAKING_SETTING", MatchMakingMgr)
MessageMgr:regist("MSG_MATCH_MAKING_FAVORITE_RET", MatchMakingMgr)